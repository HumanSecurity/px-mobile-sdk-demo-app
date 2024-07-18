//
//  ApiDataManager.swift
//  HumanDemo
//
//  Created by Oren Yaar on 20/05/2024.
//

import Foundation
import HUMAN
import UIKit

class ApiDataManager {
    
    static let shared = ApiDataManager()
    
    private let serverURL = "https://sample-ios.pxchk.net/"
    private var loginURL: URL {
        get {
            return URL(string: "\(serverURL)login")!
        }
    }
    private var productsURL: URL {
        get {
            return URL(string: "\(serverURL)products")!
        }
    }
    
    // MARK: - URL requests
    
    func sendLoginRequest(email: String, password: String, completion: @escaping (Bool, Error?) -> ()) {
        var request = URLRequest(url: URL(string: "https://sample-ios.pxchk.net/login")!)
        request.httpMethod = "GET"
        let headers = HumanSecurity.BD.headersForURLRequest(forAppId: nil)
        request.allHTTPHeaderFields = headers
        
        if HumanManager.shared.shouldSimulateBlock() {
            request.setValue("PhantomJS", forHTTPHeaderField: "user-agent")
            request.setValue("blabla", forHTTPHeaderField: "X-PX-AUTHORIZATION")
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                if HumanManager.shared.challengeOnWindow {
                    let isHandled = HumanSecurity.BD.handleResponse(response: response, data: data) { result in
                        print("challenge result = \(result)")
                    }
                    if isHandled {
                        print("block response was handled by HUMAN")
                        completion(false, nil)
                    }
                }
                else {
                    if let blockError = HumanSecurity.BD.blockResponseError(response: response, data: data) {
                        completion(false, blockError)
                        return
                    }
                }
            }
            
            var result = false
            if let response = response as? HTTPURLResponse {
                result = response.statusCode == 200
            }
            completion(result, error)
        }
        dataTask.resume()
    }
}

