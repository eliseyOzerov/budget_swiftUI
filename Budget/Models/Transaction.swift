//
//  Transaction.swift
//  Budget
//
//  Created by Elisey Ozerov on 16/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import Foundation
import RealmSwift

@objc enum TransactionType: Int, RealmEnum {
    case income
    case expense
}

@objcMembers class Transaction: Object, Identifiable {
    
    //MARK: - Properties
    dynamic var date: Date = Date()
    dynamic var total: Double = 1205.13
    dynamic var type: TransactionType = .income
    dynamic var category: String = "FUCKING BITCH"
    dynamic var secondParty: String = "Tovarna idej d.o.o."
    
    //MARK: - Initializers
    
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
        super.init()
    }
    
    //MARK: - Realm stuff
    dynamic var id: ObjectId
    override class func primaryKey() -> String? { "id" }
    
    func save(onSuccess: () -> Void, onError: () -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self, update: .modified)
            }
            onSuccess()
        } catch {
            debugPrint(error)
            onError()
        }
    }
    
    func delete(onSuccess: () -> Void, onError: () -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(self)
            }
            onSuccess()
        } catch {
            debugPrint(error)
            onError()
        }
    }
}
