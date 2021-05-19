//
//  BudgetApp.swift
//  Budget
//
//  Created by Elisey Ozerov on 24/11/2020.
//

import SwiftUI

@main
struct BudgetApp: App {
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
