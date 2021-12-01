//
//  Budget.swift
//  Budget
//
//  Created by Elisey Ozerov on 23/02/2021.
//

import Foundation
import RealmSwift

@objc enum ResetPeriod: Int, RealmEnum, Titled, Identifiable {
    case weekly
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    static var values: [ResetPeriod] {
        [.weekly,
         .monthly,
         .yearly]
    }
    
    var id: Self { self }
}

class Budget: Hashable, ObservableObject, Identifiable, Titled {
    
    var id: ObjectId = ObjectId.generate()
    @Published var title: String = "Sample Budget"
    @Published var budget: Double = 1000
    @Published var enableResets: Bool = false
    @Published var resetPeriod: ResetPeriod = .monthly
    @Published var weekdayResetSetting: Weekday?
    @Published var dayResetSetting: Int?
    @Published var monthResetSetting: Int?
    @Published var shouldAutosave: Bool = false
    @Published var autosaveTo: Fund?
    
    var lastReset: Date = Date()
    
    var nextReset: Date {
        var result: Date?
        let today = Date()
        
        // last reset value doesnt matter because user might've changed the reset day setting
        // in between resets, so we have to rely on those settings instead of the reset date

        switch resetPeriod {
        case .weekly:
            let todaysWeekdayIndex = today.weekday
            if weekdayResetSetting!.index > todaysWeekdayIndex {
                result = today.add(component: .day, value: weekdayResetSetting!.index - todaysWeekdayIndex)
            } else if weekdayResetSetting!.index < todaysWeekdayIndex {
                result = today.add(component: .day, value: 7 - (todaysWeekdayIndex - weekdayResetSetting!.index))
            }
        case .monthly:
            let currentMonthWithDaySetting = Date(from: DateComponents(year: today.year, month: today.month, day: dayResetSetting!))
            result = currentMonthWithDaySetting.add(component: .month, value: today <= currentMonthWithDaySetting ? 0 : 1)
        case .yearly:
            let currentYearWithMonthSetting = Date(from: DateComponents(year: today.year, month: monthResetSetting!, day: dayResetSetting!))
            result = currentYearWithMonthSetting.add(component: .year, value: today <= currentYearWithMonthSetting ? 0 : 1)
        }
        
        return result ?? today
    }
    
    init(){
        self.id = ObjectId.generate()
    }
    
    init(
        id: ObjectId = ObjectId.generate(),
        title: String,
        budget: Double,
        enableResets: Bool = false,
        resetPeriod: ResetPeriod = .monthly,
        weekday: Weekday? = nil,
        day: Int? = nil,
        month: Int? = nil,
        lastReset: Date = Date(),
        shouldAutosave: Bool = false,
        autosaveTo: Fund? = nil
    ) {
        self.id = id
        self.title = title
        self.budget = budget
        self.enableResets = enableResets
        self.resetPeriod = resetPeriod
        self.weekdayResetSetting = weekday
        self.dayResetSetting = day
        self.monthResetSetting = month
        self.lastReset = lastReset
        self.shouldAutosave = shouldAutosave
        self.autosaveTo = autosaveTo
        
        switch resetPeriod {
        case .weekly: assert(weekdayResetSetting != nil)
        case .monthly: assert(dayResetSetting != nil)
        case .yearly: assert(dayResetSetting != nil && monthResetSetting != nil)
        }
    }
    
    init(from db: BudgetDB) {
        self.id = db.id
        self.title = db.title
        self.budget = db.budget
        self.enableResets = db.enableResets
        self.resetPeriod = db.resetPeriod
        self.weekdayResetSetting = Weekday.allCases[db.weekday.value ?? Weekday.allCases.count]
        self.dayResetSetting = db.day.value
        self.monthResetSetting = db.month.value
        self.lastReset = db.lastReset
        self.shouldAutosave = db.shouldAutosave
        // self.autosaveTo = db.autosaveTo
        // that doesnt work so dont forget to retrieve the fund from the DB using ObjectId of that fund
        
        switch resetPeriod {
        case .weekly: assert(weekdayResetSetting != nil)
        case .monthly: assert(dayResetSetting != nil)
        case .yearly: assert(dayResetSetting != nil && monthResetSetting != nil)
        }
    }
    
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(budget)
        hasher.combine(enableResets)
        hasher.combine(resetPeriod)
        hasher.combine(weekdayResetSetting)
        hasher.combine(dayResetSetting)
        hasher.combine(monthResetSetting)
        hasher.combine(nextReset)
        hasher.combine(lastReset)
        hasher.combine(shouldAutosave)
        hasher.combine(autosaveTo)
    }
}

@objcMembers class BudgetDB: Object, Identifiable {
    dynamic var id: ObjectId = ObjectId.generate()
    dynamic var title: String = "Sample Budget"
    dynamic var budget: Double = 1000
    dynamic var enableResets: Bool = false
    dynamic var resetPeriod: ResetPeriod = .monthly
    dynamic var weekday = RealmOptional<Int>()
    dynamic var day = RealmOptional<Int>()
    dynamic var month = RealmOptional<Int>()
    dynamic var lastReset: Date = Date()
    dynamic var shouldAutosave: Bool = false
    dynamic var autosaveTo: ObjectId?
    
    override class func primaryKey() -> String? { "id" }
    
    override init() {
        self.id = ObjectId.generate()
        super.init()
    }
    
    init(from memory: Budget) {
        self.id = memory.id
        self.title = memory.title
        self.budget = memory.budget
        self.enableResets = memory.enableResets
        self.resetPeriod = memory.resetPeriod
        self.weekday = RealmOptional(memory.weekdayResetSetting?.index ?? nil)
        self.day = RealmOptional(memory.dayResetSetting)
        self.month = RealmOptional(memory.monthResetSetting)
        self.shouldAutosave = memory.shouldAutosave
        self.autosaveTo = memory.autosaveTo?.id
        self.lastReset = memory.lastReset
    }
}

