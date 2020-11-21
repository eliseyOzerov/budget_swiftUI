//
//  ContentView.swift
//  Budget
//
//  Created by Elisey Ozerov on 09/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
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
                    Image(systemName: "house").frame(width: 24, height: 24)
                    Text("Home")
                }
            TransactionListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Transactions")
                }
            WishlistView()
                .tabItem {
                    Image(systemName: "bookmark").frame(width: 24, height: 24)
                    Text("Wishlist")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape").frame(width: 24, height: 24)
                    Text("Settings")
                }
        }
    }
}
