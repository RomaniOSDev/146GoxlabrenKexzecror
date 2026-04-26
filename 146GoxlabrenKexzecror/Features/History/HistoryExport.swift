//
//  HistoryExport.swift
//  146GoxlabrenKexzecror
//

import Foundation

enum HistoryExport {
    static func csvString(from entries: [HistoryEntry]) -> String {
        var lines: [String] = [
            "Date,Activity,Level,Difficulty,Stars,Focus,Intention,Detail"
        ]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        df.locale = Locale(identifier: "en_US_POSIX")
        for e in entries {
            let f = e.focusLog?.title.replacingOccurrences(of: ",", with: " ") ?? ""
            let intention = e.focusIntention?.replacingOccurrences(of: ",", with: " ") ?? ""
            let d = e.detail.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: "\n", with: " ")
            let row = [
                df.string(from: e.date),
                e.activityKind.rawValue,
                String(e.levelIndex + 1),
                e.difficulty.title,
                String(e.starsEarned),
                f,
                intention,
                d
            ].map { v in
                v.contains(",") || v.contains("\"") ? "\"\(v.replacingOccurrences(of: "\"", with: "'"))\"" : v
            }
            .joined(separator: ",")
            lines.append(row)
        }
        return lines.joined(separator: "\n")
    }
}
