//
//  Transaction.swift
//  Budget
//
//  Created by Elisey Ozerov on 16/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import Foundation
import RealmSwift

@objc enum TransactionType: Int, RealmEnum, Identifiable, Titled {
    case income
    case expense
    case deposit
    case withdrawal
    case transfer
    
    var title: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        default: return "Expense"
        }
    }
    
    static var values: [TransactionType] {
        [.income,
         .expense]
    }
    
    var id: Self { self }
}

class Transaction: Hashable, Identifiable {

    var id: ObjectId
    var date: Date = Date()
    var total: Double = 1205.13
    var type: TransactionType = .income
    var category: String = "FUCKING BITCH"
    var secondParty: String = "Tovarna idej d.o.o."
    
    var totalSigned: Double {
        switch type {
        case .income, .withdrawal: return total
        case .expense, .deposit: return -total
        case .transfer: return 0
        }
    }

    init(from db: TransactionDB) {
        self.id = db.id
        self.date = db.date
        self.total = db.total
        self.type = db.type
        self.category = db.category
        self.secondParty = db.secondParty
    }
    
    init() {
        self.id = ObjectId.generate()
    }

    init(
        id: ObjectId = ObjectId.generate(),
        date: Date,
        total: Double,
        type: TransactionType,
        category: String,
        secondParty: String
    ) {
        self.id = id
        self.date = date
        self.total = total
        self.type = type
        self.category = category
        self.secondParty = secondParty
    }
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(total)
        hasher.combine(type)
        hasher.combine(category)
        hasher.combine(secondParty)
    }

    func fits(_ filter: TransactionFilter) -> Bool {
        return date >= (filter.dateFrom ?? date) &&
            date <= (filter.dateTo ?? date) &&
            total >= (filter.totalFrom ?? total) &&
            total <= (filter.totalTo ?? total) &&
            type == (filter.type ?? type) &&
            filter.category.map(category.contains) ?? true &&
            filter.otherParty.map(secondParty.contains) ?? true
    }

}

@objcMembers class TransactionDB: Object, Identifiable {
    
    dynamic var id: ObjectId
    dynamic var date: Date = Date()
    dynamic var total: Double = 1205.13
    dynamic var type: TransactionType = .income
    dynamic var category: String = "FUCKING BITCH"
    dynamic var secondParty: String = "Tovarna idej d.o.o."
    
    override class func primaryKey() -> String? { "id" }
    
    // needed, otherwise the super.init() initializer is ignored (bcs of the latter initializer)
    override init(){
        id = ObjectId.generate()
        super.init()
    }
    
    init(
        id: ObjectId = ObjectId.generate(),
        date: Date,
        total: Double,
        type: TransactionType,
        category: String,
        secondParty: String
    ) {
        self.id = id
        self.date = date
        self.total = total
        self.type = type
        self.category = category
        self.secondParty = secondParty
    }
    
    init(from transaction: Transaction) {
        self.id = transaction.id
        self.date = transaction.date
        self.total = transaction.total
        self.type = transaction.type
        self.category = transaction.category
        self.secondParty = transaction.secondParty
    }
    
    var totalSigned: Double {
        switch type {
        case .income, .withdrawal: return total
        case .expense, .deposit: return -total
        case .transfer: return 0
        }
    }
}
