//
//  PocketCardView.swift
//  PocketUp
//
//  Created by Erfan Yarahmadi on 10/03/26.
//

import SwiftUI

struct PocketCardView: View {
    let pocket: Pocket

    var body: some View {
        ZStack(alignment: .top) {
            // Jean-pocket shape background
            PocketShape(topCurveDepth: 22)
                .fill(LinearGradient(
                    colors: [DenimTheme.bgCard, DenimTheme.bgMid],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .overlay(
                    // Fabric weave texture
                    Canvas { ctx, size in
                        for i in stride(from: CGFloat(0), through: size.height, by: 6) {
                            var p = Path()
                            p.move(to: .init(x: 0,          y: i))
                            p.addLine(to: .init(x: size.width, y: i + 3))
                            ctx.stroke(p, with: .color(.white.opacity(0.015)), lineWidth: 1)
                        }
                    }
                    .clipShape(PocketShape(topCurveDepth: 22))
                )
                .overlay(
                    // Gold stitch outline
                    PocketShape(topCurveDepth: 22)
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        .foregroundColor(DenimTheme.stitchGold.opacity(pocket.isActive ? 0.6 : 0.2))
                        .padding(3)
                )
                .shadow(color: DenimTheme.shadowBlue.opacity(0.6), radius: 12, x: 0, y: 6)

            // Content
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(pocket.color.opacity(0.25))
                            .frame(width: 44, height: 44)
                        Image(systemName: pocket.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(pocket.color)
                    }
                    Spacer()
                    Circle()
                        .fill(pocket.isActive ? Color.green : DenimTheme.fadedDenim.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .shadow(color: pocket.isActive ? Color.green.opacity(0.6) : .clear, radius: 4)
                }
                .padding(.horizontal, 14)
                .padding(.top, 16)

                Text(pocket.name)
                    .font(DenimTheme.titleFont(18))
                    .foregroundColor(DenimTheme.fabricWhite)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.top, 10)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(DenimTheme.stitchGold)
                    Text(pocket.destination)
                        .font(DenimTheme.labelFont(10))
                        .foregroundColor(DenimTheme.fadedDenim)
                        .lineLimit(1)
                }
                .padding(.horizontal, 14)
                .padding(.top, 3)

                Spacer(minLength: 10)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 11))
                            .foregroundColor(DenimTheme.stitchGold.opacity(0.8))
                        Text("\(pocket.items.count) item\(pocket.items.count == 1 ? "" : "s")")
                            .font(DenimTheme.labelFont(11))
                            .foregroundColor(DenimTheme.paleDenim)
                    }

                    if !pocket.schedule.daysOfWeek.isEmpty {
                        HStack(spacing: 3) {
                            ForEach(0..<7) { i in
                                let isOn = pocket.schedule.daysOfWeek.contains(i + 1)
                                Text(["S","M","T","W","T","F","S"][i])
                                    .font(.system(size: 9, weight: .bold))
                                    .frame(width: 18, height: 18)
                                    .background(isOn ? pocket.color.opacity(0.8) : DenimTheme.bgMid)
                                    .foregroundColor(isOn ? .white : DenimTheme.fadedDenim.opacity(0.4))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
        }
        .frame(height: 180)
        .opacity(pocket.isActive ? 1.0 : 0.6)
    }
}

#Preview {
    ZStack {
        DenimTextureBackground()
        HStack {
            PocketCardView(pocket: Pocket.preview)
            PocketCardView(pocket: Pocket.previews[1])
        }
        .padding()
    }
}
