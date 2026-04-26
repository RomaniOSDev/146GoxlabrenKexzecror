//
//  ActivityShareView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI
import UIKit

struct ActivityShareView: UIViewControllerRepresentable {
    var csvText: String
    var filename: String = "flow_sessions.csv"

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("share_\(UUID().uuidString.prefix(8))_\(filename)")
        if let d = csvText.data(using: .utf8) {
            try? d.write(to: url, options: .atomic)
        } else {
            try? Data().write(to: url)
        }
        return UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ viewController: UIActivityViewController, context: Context) {
    }
}
