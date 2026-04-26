//
//  AppExternalURL.swift
//  146GoxlabrenKexzecror
//  All outbound policy / legal URLs in one place. Replace strings when you ship.
//

import Foundation
import UIKit

/// External links for Settings: Privacy, Terms. (Rate uses `SKStoreReviewController`, not a URL here.)
enum AppExternalURL: String, CaseIterable {
    case privacyPolicy = "https://goxlabrenkexzecror146.site/privacy/122"
    case termsOfUse = "https://goxlabrenkexzecror146.site/terms/122"

    var url: URL? {
        URL(string: rawValue)
    }

    /// Opens the link in the default browser if the string is a valid URL.
    func openInBrowser() {
        if let url = url {
            UIApplication.shared.open(url)
        }
    }
}
