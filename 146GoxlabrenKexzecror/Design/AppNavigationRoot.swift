//
//  AppNavigationRoot.swift
//  146GoxlabrenKexzecror
//  Paints a solid app-tint layer behind SwiftUI content inside NavigationStack (avoids black UIKit fill).
//

import SwiftUI

struct AppNavigationRoot<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppColor.background
                    .ignoresSafeArea()
                content()
            }
        }
        .toolbarBackground(Color.clear, for: .navigationBar)
    }
}
