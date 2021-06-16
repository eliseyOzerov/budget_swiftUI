//
//  Fund.swift
//  Budget
//
//  Created by Elisey Ozerov on 16/02/2021.
//

import Foundation
import RealmSwift

class Fund: Hashable, Identifiable, ObservableObject, Titled, RealmOptionalType {
    
    var id: ObjectId?
    @Published var title: String = "SomeTitle"
    @Published var goal: Double = 120
    
    init(){
        self.id = ObjectId.generate()
    }
    
    init(id: ObjectId? = nil, title: String, goal: Double) {
        self.id = id ?? ObjectId.generate()
        self.title = title
        self.goal = goal
    }
    
    static func == (lhs: Fund, rhs: Fund) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(goal)
    }
    
    init(from fundDB: FundDB) {
        self.id = fundDB.id
        self.title = fundDB.title
        self.goal = fundDB.goal
    }
}

@objcMembers class FundDB: Object {
    dynamic var id: ObjectId
    dynamic var title: String = ""
    dynamic var goal: Double = 0
    
    override class func primaryKey() -> String? { "id" }
    
    override init() {
        self.id = ObjectId.generate()
        super.init()
    }
    
    init(from other: Fund) {
        self.id = other.id ?? ObjectId.generate()
        self.title = other.title
        self.goal = other.goal
    }
}
