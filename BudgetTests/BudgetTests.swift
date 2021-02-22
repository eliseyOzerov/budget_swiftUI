//
//  BudgetTests.swift
//  BudgetTests
//
//  Created by Elisey Ozerov on 24/11/2020.
//

import XCTest
@testable import Budget

class BudgetTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

class AuthenticatorTests: XCTestCase {
    func testEmailPasswordCorrectLogin() throws {
        let promise = expectation(description: "true")
        
        Authenticator().emailPasswordLogin(email: "eliseyozerov@outlook.com", password: "Iwilalnaiwg$*!1", onSuccess: { user in
            promise.fulfill()
        }, onError: { error in
            XCTFail("Error logging in: \(error.message)")
        })
        
        wait(for: [promise], timeout: 5)
    }
    
    func testEmailPasswordIncorrectLogin() throws {
        let promise = expectation(description: "true")
        
        Authenticator().emailPasswordLogin(email: "eliseyozerovm", password: "1", onSuccess: { user in
            XCTFail("Logged in successfully: \(user.email)")
        }, onError: { error in
            promise.fulfill()
        })
        
        wait(for: [promise], timeout: 5)
    }
}
