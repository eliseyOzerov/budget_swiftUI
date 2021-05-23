//
//  BudgetApp.swift
//  Budget
//
//  Created by Elisey Ozerov on 24/11/2020.
//

import SwiftUI

@main
struct BudgetApp: App {
    // having these objects in a lower level (ContentView) causes a weird bug
    // where saving a budget without doing anything to it sometimes crashes the app
    // due to there being no "Observable object of type SavingsViewModel" *shrug*
    @ObservedObject var savingsViewModel = SavingsViewModel()
    @ObservedObject var transactionListViewModel = TransactionsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(savingsViewModel)
                .environmentObject(transactionListViewModel)
        }
    }
}
