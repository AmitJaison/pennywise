// PennyWiseSwift/PennyWise/Views/Shared/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
            PassbookView()
                .tabItem { Label("Passbook", systemImage: "book.fill") }
            AnalysisView()
                .tabItem { Label("Analysis", systemImage: "chart.pie.fill") }
        }
    }
}
