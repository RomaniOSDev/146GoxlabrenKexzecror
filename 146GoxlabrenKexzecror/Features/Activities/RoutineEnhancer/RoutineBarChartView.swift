//
//  RoutineBarChartView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct RoutineBarChartView: View {
    var items: [RoutineBlockItem]

    var body: some View {
        let maxM = max(items.map { $0.minutes }.max() ?? 1, 1)
        return Canvas { context, size in
            let w = size.width
            let h = size.height
            let c = max(items.count, 1)
            let col = w / CGFloat(c) - 2
            for (i, b) in items.enumerated() {
                let barH = CGFloat(b.minutes) / CGFloat(maxM) * h * 0.85
                let x = CGFloat(i) * (w / CGFloat(c)) + 1
                let y = h - barH
                var p = Path()
                p.addRoundedRect(
                    in: CGRect(x: x, y: y, width: max(0, col), height: max(0, barH)),
                    cornerSize: CGSize(width: 4, height: 4),
                    style: .continuous
                )
                let accent = AppColor.accent
                context.fill(
                    p,
                    with: .color(accent)
                )
            }
        }
        .frame(height: 84)
    }
}
