//
//  FocusRingChartView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct FocusRingChartView: View {
    var progress: Double
    var lineWidth: CGFloat = 16

    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height)
            let r = s / 2 - lineWidth
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let track = AppColor.surface
            let head = AppColor.primary
            var back = Path()
            back.addArc(
                center: center,
                radius: r,
                startAngle: .degrees(-90),
                endAngle: .degrees(270),
                clockwise: false
            )
            context.stroke(back, with: .color(track), lineWidth: lineWidth)
            var p = min(1, max(0, progress))
            var fr = Path()
            fr.addArc(
                center: center,
                radius: r,
                startAngle: .degrees(-90),
                endAngle: .degrees(-90 + 360 * p),
                clockwise: false
            )
            context.stroke(
                fr,
                with: .color(head),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
