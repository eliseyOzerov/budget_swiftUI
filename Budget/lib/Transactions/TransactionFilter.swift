//
//  TransactionFilter.swift
//  Budget
//
//  Created by Elisey Ozerov on 05/01/2021.
//

import Foundation

class TransactionFilter: ObservableObject {
    @Published var type: TransactionType?
    @Published var category: String?
    @Published var otherParty: String?
    @Published var dateFrom: Date?
    @Published var dateTo: Date?
    @Published var totalFrom: Double?
    @Published var totalTo: Double?
    
    func reset() {
        type = nil
        category = nil
        otherParty = nil
        dateFrom = nil
        dateTo = nil
        totalFrom = nil
        totalTo = nil
    }
}
