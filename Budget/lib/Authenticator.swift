//
//  Authenticator.swift
//  Budget
//
//  Created by Elisey Ozerov on 06/12/2020.
//

import Foundation
import RealmSwift

class Authenticator: AuthenticatorProtocol {
    
    struct Error {
        let message: String
    }
    
    struct CurrentUser {
        let email: String
    }
    
    private let authenticator: AuthenticatorProtocol = MongoAtlasAuthenticator()
    
    func emailPasswordLogin(email: String, password: String, onSuccess: @escaping (CurrentUser) -> Void, onError: @escaping (Error) -> Void) {
        authenticator.emailPasswordLogin(email: email, password: password, onSuccess: onSuccess, onError: onError)
    }
    
    func logout() {
        authenticator.logout()
    }
}

fileprivate protocol AuthenticatorProtocol {
    
    func emailPasswordLogin(email: String, password: String, onSuccess: @escaping (Authenticator.CurrentUser) -> Void, onError: @escaping (Authenticator.Error) -> Void)
    
    func logout()
}

 fileprivate class MongoAtlasAuthenticator: AuthenticatorProtocol {
    
    let app = App(id: "budget-dzegj")
    
    func emailPasswordLogin(email: String, password: String, onSuccess: @escaping (Authenticator.CurrentUser) -> Void, onError: @escaping (Authenticator.Error) -> Void) {
        app.login(credentials: Credentials.emailPassword(email: email, password: password)) { (result) in
            switch result {
            case .failure(let error):
                onError(Authenticator.Error(message: error.localizedDescription))
            case .success(let user):
                print(user)
                onSuccess(Authenticator.CurrentUser(email: user.description))
            }
        }
    }
    
    func logout() {
        app.currentUser?.logOut { (error) in
            // user is logged out or there was an error
        }
    }
}
