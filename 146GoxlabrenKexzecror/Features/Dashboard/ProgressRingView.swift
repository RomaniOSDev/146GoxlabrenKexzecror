//
//  ProgressRingView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct ProgressRingView: View {
    var progress: Double
    var lineWidth: CGFloat = 14

    var body: some View {
        Canvas { context, size in
            let w = min(size.width, size.height)
            let r = w / 2 - lineWidth / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            var base = Path()
            base.addArc(
                center: center,
                radius: r,
                startAngle: .degrees(-90),
                endAngle: .degrees(270),
                clockwise: false
            )
            let track = AppColor.surface
            let fill = AppColor.accent
            context.stroke(
                base,
                with: .color(track),
                lineWidth: lineWidth
            )
            var arc = Path()
            let p = min(1, max(0, progress))
            arc.addArc(
                center: center,
                radius: r,
                startAngle: .degrees(-90),
                endAngle: .degrees(-90 + 360 * p),
                clockwise: false
            )
            context.stroke(
                arc,
                with: .color(fill),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
