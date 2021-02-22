//
//  ContentView.swift
//  Budget
//
//  Created by Elisey Ozerov on 09/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    func styleNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .systemGroupedBackground
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    init() {
        styleNavBar()
    }
    
    var body: some View {
        MainView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
            SavingsView()
                .tabItem {
                    Label("Savings", systemImage: "bitcoinsign.circle")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
