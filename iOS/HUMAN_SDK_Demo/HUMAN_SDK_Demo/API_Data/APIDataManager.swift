//
//  APIDataManager.swift
//  HUMAN_SDK_Demo
//
//  Created by HUMAN.
//

import Foundation
import UIKit
import HUMAN

class APIDataManager {
    
    // MARK: - singleton
    
    static let shared = APIDataManager()
    
    // MARK: - properties
    
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
    
    func sendLoginRequest(email: String, password: String, completion: @escaping (Bool) -> ()) {
        let request = requestForURL(url: loginURL)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, url: self.loginURL.absoluteString, error: error)
            
            var result = false
            if let response = response as? HTTPURLResponse {
                result = response.statusCode == 200
            }
            completion(result)
        }
        dataTask.resume()
    }
    
    func sendProductsRequest(completion: @escaping ([Product]?) -> ()) {
        let request = requestForURL(url: productsURL)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, url: self.productsURL.absoluteString, error: error)
            
            var products: [Product]?
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        products = try decoder.decode([Product].self, from: data)
                    }
                    catch {
                        print("error: \(error)")
                    }
                }
            }
            completion(products)
        }
        dataTask.resume()
    }
    
    func loadImage(url: String, completion: @escaping (UIImage?) -> ()) {
        let request = requestForURL(url: URL(string: url)!)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data, url: url, error: error)
            
            var image: UIImage?
            if let data = data {
                image = UIImage(data: data)
            }
            completion(image)
        }
        dataTask.resume()
    }
    
    private func requestForURL(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // When HSPolicy.automaticInterceptorPolicy.interceptorType is set to `HSAutomaticInterceptorType/none` => get HTTP headers from HUMAN and add them to your request //
        if HumanManager.shared.urlRequestInterceptionType == .none {
            let headers = HumanSecurity.BD.headersForURLRequest(forAppId: nil)
            request.allHTTPHeaderFields = headers
        }
        
        return request
    }
    
    private func handleResponse(data: Data?, url: String?, error: Error?) {
        if let error = (error as? NSError), error.domain == HSBotDefenderErrorDomain {
            // When HSPolicy.automaticInterceptorPolicy.interceptorType is set to any value rather than `HSAutomaticInterceptorType/none`  => check that the error is "Request blocked by HUMAN" //
            if HumanManager.shared.urlRequestInterceptionType != .none {
                switch (error.code) {
                case HSBotDefenderErrorType.requestWasBlocked.rawValue:
                    print("request was blocked by HUMAN")
                case HSBotDefenderErrorType.challengeWasSolved.rawValue:
                    print("request was blocked by HUMAN and user solved the challenge")
                case HSBotDefenderErrorType.challengeWasCancelled.rawValue:
                    print("request was blocked by HUMAN and challenge was cancelled")
                default:
                    break
                }
            }
        }
        
        if let data = data {
            // When HSPolicy.automaticInterceptorPolicy.interceptorType is set to `HSAutomaticInterceptorType/none` => pass the data and response to HUMAN to handle it //
            if HumanManager.shared.urlRequestInterceptionType == .none {
                let isHandledByPX = HumanSecurity.BD.handleBlockResponse(data: data, url: url) { result in
                    print("challenge result = \(result)")
                }
                if isHandledByPX {
                    print("block response was handled by HUMAN")
                }
            }
        }
    }
}
