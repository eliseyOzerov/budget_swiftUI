//
//  BudgetTests.swift
//  BudgetTests
//
//  Created by Elisey Ozerov on 24/11/2020.
//

import XCTest
@testable import Budget

class BudgetResetTests: XCTestCase {
    
    func test_ShouldResetBudgetLastResetToday() {
        let model = BudgetsViewModel()
        let weekday = Weekday.allCases[Date().weekday]
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .weekly, weekday: weekday, shouldAutosave: false, autosaveTo: nil)
        let shouldReset = model.shouldResetBudget(budget)
        XCTAssertFalse(shouldReset)
    }
    
    func test_ShouldResetBudgetLastResetEarlier() {
        let model = BudgetsViewModel()
        let weekday = Weekday.allCases[Date().weekday]
        let lastReset = Date().subtract(component: .day, value: 7)
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .weekly, weekday: weekday, lastReset: lastReset, shouldAutosave: false, autosaveTo: nil)
        let shouldReset = model.shouldResetBudget(budget)
        XCTAssertTrue(shouldReset)
    }
    
    func test_BudgetWeeklyNextResetToday() {
        let weekday = Weekday.allCases[Date().weekday]
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .weekly, weekday: weekday, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == Date().day)
    }
    
    func test_BudgetWeeklyNextResetBefore() {
        let date = Date().subtract(component: .day, value: 2)
        let weekday = Weekday.allCases[date.weekday]
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .weekly, weekday: weekday, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == date.add(component: .day, value: 7).day)
    }
    
    func test_BudgetWeeklyNextResetAfter() {
        let date = Date().add(component: .day, value: 2)
        let weekday = Weekday.allCases[date.weekday]
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .weekly, weekday: weekday, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == date.day)
    }
    
    func test_BudgetMonthlyNextResetToday() {
        let date = Date().subtract(component: .month, value: 1)
        let nextResetExpectation = Date()
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .monthly, day: date.day, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == nextResetExpectation.day)
    }
    
    func test_BudgetMonthlyNextResetBefore() {
        let date = Date().subtract(component: .day, value: 15)
        let nextResetExpectation = date.add(component: .month, value: 1)
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .monthly, day: date.day, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == nextResetExpectation.day)
    }
    
    func test_BudgetMonthlyNextResetAfter() {
        let date = Date().add(component: .day, value: 15)
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .monthly, day: date.day, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == date.day)
    }
    
    func test_BudgetYearlyNextResetToday() {
        let date = Date().subtract(component: .year, value: 1)
        let nextResetExpectation = Date()
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .yearly, day: date.day, month: date.month, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == nextResetExpectation.day && budget.nextReset.month == nextResetExpectation.month)
    }

    func test_BudgetYearlyNextResetBefore() {
        let date = Date().subtract(component: .month, value: 5)
        let nextResetExpectation = date.add(component: .year, value: 1)
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .yearly, day: date.day, month: date.month, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == nextResetExpectation.day && budget.nextReset.month == nextResetExpectation.month)
    }

    func test_BudgetYearlyNextResetAfter() {
        let date = Date().add(component: .month, value: 5)
        let budget = Budget(id: nil, title: "TestBudget", budget: 1000, enableResets: true, resetPeriod: .yearly, day: date.day, month: date.month, shouldAutosave: false, autosaveTo: nil)
        XCTAssert(budget.nextReset.day == date.day && budget.nextReset.month == date.month)
    }
}

//class AuthenticatorTests: XCTestCase {
//    func testEmailPasswordCorrectLogin() throws {
//        let promise = expectation(description: "true")
//
//        Authenticator().emailPasswordLogin(email: "eliseyozerov@outlook.com", password: "Iwilalnaiwg$*!1", onSuccess: { user in
//            promise.fulfill()
//        }, onError: { error in
//            XCTFail("Error logging in: \(error.message)")
//        })
//
//        wait(for: [promise], timeout: 5)
//    }
//
//    func testEmailPasswordIncorrectLogin() throws {
//        let promise = expectation(description: "true")
//
//        Authenticator().emailPasswordLogin(email: "eliseyozerovm", password: "1", onSuccess: { user in
//            XCTFail("Logged in successfully: \(user.email)")
//        }, onError: { error in
//            promise.fulfill()
//        })
//
//        wait(for: [promise], timeout: 5)
//    }
//}
