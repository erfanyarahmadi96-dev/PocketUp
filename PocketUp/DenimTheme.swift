//
//  DenimTheme.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//


import SwiftUI

// MARK: - Denim Theme
struct DenimTheme {
    static let denim         = Color(hex: "#2B4C7E") ?? .blue
    static let lightDenim    = Color(hex: "#3A6BC4") ?? .blue
    static let fadedDenim    = Color(hex: "#6B8DBE") ?? .blue
    static let paleDenim     = Color(hex: "#B8C9E1") ?? .blue
    static let rawDenim      = Color(hex: "#1A3055") ?? .blue
    static let bleachedDenim = Color(hex: "#D4DFF0") ?? .blue
    static let stitchGold    = Color(hex: "#C9A84C") ?? .yellow
    static let stitchOrange  = Color(hex: "#D4742A") ?? .orange
    static let fabricWhite   = Color(hex: "#F0EDE6") ?? .white
    static let shadowBlue    = Color(hex: "#0D1F35") ?? .black
    static let bgDeep        = Color(hex: "#0F1E2E") ?? .black
    static let bgMid         = Color(hex: "#162840") ?? .black
    static let bgCard        = Color(hex: "#1E3454") ?? .blue

    static func titleFont(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
    static func bodyFont(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    static func labelFont(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
}

// MARK: - Denim Texture Background
struct DenimTextureBackground: View {
    var body: some View {
        ZStack {
            DenimTheme.bgDeep
            Canvas { ctx, size in
                let spacing: CGFloat = 8
                let warp  = Color.white.opacity(0.025)
                let weft  = Color.white.opacity(0.018)
                // warp threads
                var x: CGFloat = -size.height
                while x < size.width + size.height {
                    var p = Path()
                    p.move(to: .init(x: x, y: 0))
                    p.addLine(to: .init(x: x + size.height * 0.3, y: size.height))
                    ctx.stroke(p, with: .color(warp), lineWidth: 1)
                    x += spacing
                }
                // weft threads
                var y: CGFloat = -size.width
                while y < size.height + size.width {
                    var p = Path()
                    p.move(to: .init(x: 0, y: y))
                    p.addLine(to: .init(x: size.width, y: y + size.width * 0.15))
                    ctx.stroke(p, with: .color(weft), lineWidth: 0.8)
                    y += spacing * 1.2
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Stitch Border
struct StitchBorder: ViewModifier {
    var color: Color       = DenimTheme.stitchGold
    var cornerRadius: CGFloat = 16
    var dash: [CGFloat]    = [6, 4]

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: dash))
                .foregroundColor(color.opacity(0.7))
                .padding(3)
        )
    }
}

extension View {
    func stitchBorder(color: Color = DenimTheme.stitchGold, cornerRadius: CGFloat = 16) -> some View {
        modifier(StitchBorder(color: color, cornerRadius: cornerRadius))
    }
}

// MARK: - Pocket Shape (jean-pocket curved opening)
struct PocketShape: Shape {
    var topCurveDepth: CGFloat = 18

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r: CGFloat = 16
        path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        // curved top opening
        path.addLine(to: CGPoint(x: rect.midX - 30, y: rect.minY))
        path.addQuadCurve(
            to:      CGPoint(x: rect.midX + 30, y: rect.minY),
            control: CGPoint(x: rect.midX,      y: rect.minY + topCurveDepth)
        )
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY  + r), radius: r, startAngle: .degrees(-90), endAngle: .degrees(  0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY  - r), radius: r, startAngle: .degrees(  0), endAngle: .degrees( 90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY  - r), radius: r, startAngle: .degrees( 90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY  + r), radius: r, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Spring Button Style
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
