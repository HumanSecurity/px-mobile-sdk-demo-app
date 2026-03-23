//
//  HumanManager.swift
//  HUMAN_SDK_Demo
//
//  Created by HUMAN.
//

import Foundation
import HUMAN

class HumanManager: NSObject, HSBotDefenderDelegate {
    
    // MARK: - HSBotDefenderDelegate
    
    func botDefenderRequestBlocked(url: URL?, appId: String) {
        print("Request Blocked")
    }
    
    func botDefenderChallengeSolved(forAppId appId: String) {
        print("Challenge Solved")
    }
    
    func botDefenderChallengeCancelled(forAppId appId: String) {
        print("Challenge Cancelled")
    }
    
    func botDefenderChallengeRendered(forAppId appId: String) {
        print("Challenge Rendered")
    }
    
    func botDefenderChallengeRenderFailed(forAppId appId: String) {
        print("Challenge Render Failed")
    }
    
    func botDefenderDidUpdateHeaders(headers: [String : String], forAppId appId: String) {
        print("Headers Were Updated")
    }
    
    // MARK: - singleton
    
    static let shared = HumanManager()
    
    // MARK: - properties
    
    private let pxAppId = "PXj9y4Q8Em"
    let urlRequestInterceptionType: HSAutomaticInterceptorType = .interceptWithDelayedResponse
    
    // MARK: - HUMAN
    
    func start() {
        print("SDK version: \(HumanSecurity.sdkVersion())")
        
        start(appId: pxAppId)
        setCustomParameters()
    }
    
    private func start(appId: String) {
        // Create and config the policy //
        let policy = HSPolicy()
        policy.automaticInterceptorPolicy.interceptorType = urlRequestInterceptionType
        policy.automaticInterceptorPolicy.set(interceptedDomains: ["sample-ios.pxchk.net"], forAppId: appId)
        policy.doctorAppPolicy.enabled = true
        
        
        // Start HUMAN SDK with your AppID //
        do {
            try HumanSecurity.start(appId: appId, policy: policy)
            HumanSecurity.BD.delegate = self
        }
        catch {
            print("error: \(error)")
        }
    }
    
    private func setCustomParameters() {
        var customParameters = [String: String]()
        customParameters["custom_param1"] = "hello"
        customParameters["custom_param2"] = "world"
        do {
            try HumanSecurity.BD.setCustomParameters(parameters: customParameters, forAppId: pxAppId)
        }
        catch {
            print("error: \(error)")
        }
    }
}
