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

// MARK: - Procedural Denim Texture
struct DenimTextureBackground: View {

    var body: some View {
        ZStack {

            // Base denim color
            DenimTheme.rawDenim

            // Subtle color variation
            LinearGradient(
                colors: [
                    DenimTheme.rawDenim,
                    DenimTheme.denim,
                    DenimTheme.bgDeep
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.multiply)
            .opacity(0.6)

            // Twill weave pattern
            Canvas { ctx, size in

                let spacing: CGFloat = 6
                let slope: CGFloat = 0.65

                var x: CGFloat = -size.height

                while x < size.width + size.height {

                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(
                        x: x + size.height * slope,
                        y: size.height
                    ))

                    ctx.stroke(
                        path,
                        with: .color(Color.white.opacity(0.07)),
                        lineWidth: 1.4
                    )

                    x += spacing
                }

                // Secondary weave layer (offset)
                var x2: CGFloat = -size.height + spacing/2

                while x2 < size.width + size.height {

                    var path = Path()
                    path.move(to: CGPoint(x: x2, y: 0))
                    path.addLine(to: CGPoint(
                        x: x2 + size.height * slope,
                        y: size.height
                    ))

                    ctx.stroke(
                        path,
                        with: .color(Color.white.opacity(0.035)),
                        lineWidth: 1
                    )

                    x2 += spacing
                }
            }

            // Fiber noise layer
            Canvas { ctx, size in

                let fiberCount = 3500

                for _ in 0..<fiberCount {

                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)

                    var dot = Path()
                    dot.addEllipse(
                        in: CGRect(
                            x: x,
                            y: y,
                            width: 1,
                            height: 1
                        )
                    )

                    ctx.fill(
                        dot,
                        with: .color(Color.white.opacity(0.025))
                    )
                }
            }
            .blendMode(.overlay)

        }
        .ignoresSafeArea()
    }
}

// MARK: - Stitch Border
struct StitchBorder: ViewModifier {
    var color: Color = DenimTheme.stitchGold
    var cornerRadius: CGFloat = 16
    var dash: [CGFloat] = [6, 4]

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    style: StrokeStyle(
                        lineWidth: 1.5,
                        dash: dash
                    )
                )
                .foregroundColor(color.opacity(0.7))
                .padding(3)
        )
    }
}

extension View {
    func stitchBorder(
        color: Color = DenimTheme.stitchGold,
        cornerRadius: CGFloat = 16
    ) -> some View {
        modifier(
            StitchBorder(
                color: color,
                cornerRadius: cornerRadius
            )
        )
    }
}

// MARK: - Pocket Shape
struct PocketShape: Shape {

    var topCurveDepth: CGFloat = 18

    func path(in rect: CGRect) -> Path {

        var path = Path()
        let r: CGFloat = 16

        path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.midX - 30, y: rect.minY))

        path.addQuadCurve(
            to: CGPoint(x: rect.midX + 30, y: rect.minY),
            control: CGPoint(
                x: rect.midX,
                y: rect.minY + topCurveDepth
            )
        )

        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))

        path.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))

        path.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))

        path.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))

        path.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()

        return path
    }
}

// MARK: - Spring Button Style
struct SpringButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {

        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(
                .spring(
                    response: 0.25,
                    dampingFraction: 0.6
                ),
                value: configuration.isPressed
            )
    }
}
