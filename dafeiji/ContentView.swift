//
//  ContentView.swift
//  dafeiji
//
//  Created by 杨恒 on 2025/3/11.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = DataStore()
    @State private var isAuthenticated = false
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !isAuthenticated {
                LoginView(isAuthenticated: $isAuthenticated)
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .environmentObject(dataStore)
                        .tabItem {
                            Label("统计", systemImage: "chart.pie")
                        }
                        .tag(0)
                    
                    RecordView()
                        .environmentObject(dataStore)
                        .tabItem {
                            Label("记录", systemImage: "plus.circle")
                        }
                        .tag(1)
                    
                    HistoryView()
                        .environmentObject(dataStore)
                        .tabItem {
                            Label("历史", systemImage: "clock.arrow.circlepath")
                        }
                        .tag(2)
                    
                    AnalyticsView()
                        .environmentObject(dataStore)
                        .tabItem {
                            Label("分析", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .tag(3)
                    
                    SettingsView(isAuthenticated: $isAuthenticated)
                        .environmentObject(dataStore)
                        .tabItem {
                            Label("设置", systemImage: "gear")
                        }
                        .tag(4)
                }
                .accentColor(.blue)
            }
        }
        .onAppear {
            // 在实际应用中，这里应检查用户是否已设置app锁定
            // 如果设置了锁定，则isAuthenticated应为false，否则为true
            if dataStore.settings.appLock {
                isAuthenticated = false
            } else {
                isAuthenticated = true
            }
        }
    }
}
    
#Preview {
    ContentView()
}
