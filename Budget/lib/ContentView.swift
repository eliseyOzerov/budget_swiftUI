//
//  ContentView.swift
//  Budget
//
//  Created by Elisey Ozerov on 09/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI
import RealmSwift

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
    
//    init() {
//        let config = Realm.Configuration(
//            schemaVersion: 2, // Set the new schema version.
//            migrationBlock: { migration, oldSchemaVersion in
//                if oldSchemaVersion < 2 {
//                    // The enumerateObjects(ofType:_:) method iterates over
//                    // every Person object stored in the Realm file
//                    migration.enumerateObjects(ofType: Person.className()) { oldObject, newObject in
//                        // combine name fields into a single field
//                        let firstName = oldObject!["firstName"] as? String
//                        let lastName = oldObject!["lastName"] as? String
//                        newObject!["fullName"] = "\(firstName!) \(lastName!)"
//                    }
//                }
//            }
//        )
//
//        Realm.Configuration.defaultConfiguration = config
//    }
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGroupedBackground
    }
    
    var body: some View {
        TabView {
//            OverviewView()
//                .tabItem {
//                    Label("Overview", systemImage: "creditcard")
//                }
            BudgetsView()
                .tabItem {
                    Label("Budget", systemImage: "creditcard")
                }
            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
            SavingsView()
                .tabItem {
                    Label("Savings", systemImage: "bitcoinsign.circle")
                }
//            SettingsView()
//                .tabItem {
//                    Label("Settings", systemImage: "gearshape")
//                }
        }
    }
}
