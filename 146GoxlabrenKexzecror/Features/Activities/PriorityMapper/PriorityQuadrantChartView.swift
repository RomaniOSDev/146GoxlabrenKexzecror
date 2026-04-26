//
//  PriorityQuadrantChartView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct PriorityQuadrantChartView: View {
    var counts: [Int]

    var body: some View {
        Canvas { context, size in
            let a = size.width * 0.5
            let b = size.height * 0.5
            let r0 = CGRect(x: 0, y: 0, width: a, height: b)
            let r1 = CGRect(x: a, y: 0, width: a, height: b)
            let r2 = CGRect(x: 0, y: b, width: a, height: b)
            let r3 = CGRect(x: a, y: b, width: a, height: b)
            let all = [r0, r1, r2, r3]
            for (i, rect) in all.enumerated() {
                var p = Path()
                p.addRoundedRect(in: rect, cornerSize: CGSize(width: 6, height: 6), style: .continuous)
                let w = (i < counts.count) ? counts[i] : 0
                let op: Double = w > 0 ? 1.0 : 0.62
                let c: Color
                switch i {
                case 0: c = AppColor.surface
                case 1: c = AppColor.primary.opacity(0.35)
                case 2: c = AppColor.accent.opacity(0.3)
                default: c = AppColor.textSecondary.opacity(0.2)
                }
                context.fill(p, with: .color(c.opacity(op)))
            }
        }
    }
}
