//
//  ViewModel.swift
//  HumanDemo
//
//  Created by Oren Yaar on 21/05/2024.
//

import Foundation
import HUMAN

@Observable
class ViewModel {
    
    let apiDataManager = ApiDataManager()
    var loginError: Error?
    var isLoggedIn = false
    let challengeUUID = UUID().uuidString
    
    func performLogin() {
        apiDataManager.sendLoginRequest(email: "", password: "") { [weak self] result, error in
            guard let `self` = self else { return }
            self.isLoggedIn = result
            self.loginError = error
            if let error {
                HumanSecurity.BD.handleBlockError(error: error, uuid: challengeUUID) { result in
                    print("challenge result = \(result)")
                }
            }
        }
    }
}
