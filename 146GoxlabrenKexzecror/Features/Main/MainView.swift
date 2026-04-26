//
//  MainView.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var app: AppData
    @State private var selectedTab: AppTab = .home
    @State private var addTaskOpen = false

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    AppNavigationRoot {
                        HomeView(
                            onAddTask: { addTaskOpen = true }
                        )
                    }
                case .history:
                    AppNavigationRoot {
                        HistoryView()
                    }
                case .goals:
                    AppNavigationRoot {
                        GoalsView(
                            onAddTask: { addTaskOpen = true }
                        )
                    }
                case .settings:
                    AppNavigationRoot {
                        SettingsView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selection: $selectedTab)
        }
        .appScreenBackground()
        .onReceive(NotificationCenter.default.publisher(for: .appDataDidReset)) { _ in
            // SwiftUI will refresh with environment object changes.
        }
        .sheet(isPresented: $addTaskOpen) {
            AddTaskSheet()
                .environmentObject(app)
                .presentationBackground(AppColor.background)
        }
        .fullScreenCover(item: $app.focusLaunch) { item in
            AppNavigationRoot {
                FocusPulseView(levelIndex: item.levelIndex, initialMinutes: item.minutes)
            }
            .environmentObject(app)
            .presentationBackground(AppColor.background)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppData())
}
