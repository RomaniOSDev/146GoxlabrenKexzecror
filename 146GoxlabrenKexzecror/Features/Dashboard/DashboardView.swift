//
//  DashboardView.swift
//  146GoxlabrenKexzecror
//  Legacy name — the main screen is `HomeView`.
//

import SwiftUI

struct DashboardView: View {
    var onAddTask: () -> Void

    var body: some View {
        HomeView(onAddTask: onAddTask)
    }
}

#Preview {
    NavigationStack {
        DashboardView(onAddTask: { })
    }
    .environmentObject(AppData())
}
