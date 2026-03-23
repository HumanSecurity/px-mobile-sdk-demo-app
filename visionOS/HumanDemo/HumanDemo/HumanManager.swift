//
//  HumanManager.swift
//  HumanDemo
//
//  Created by Oren Yaar on 20/05/2024.
//

import Foundation
import HUMAN

class HumanManager: NSObject, HSBotDefenderDelegate {
    
    // MARK: - HSBotDefenderDelegate
    
    func botDefenderRequestBlocked(url: URL?, appId: String) {
        print("HUMAN Request was blocked")
    }
    
    func botDefenderChallengeSolved(forAppId appId: String) {
        print("HUMAN Challenge was solved")
    }
    
    func botDefenderChallengeCancelled(forAppId appId: String) {
        print("HUMAN Challenge was cancelled")
    }
    
    func botDefenderChallengeRendered(forAppId appId: String) {
        print("HUMAN Challenge was rendered")
    }
    
    func botDefenderChallengeRenderFailed(forAppId appId: String) {
        print("HUMAN Challenge render was failed")
    }
    
    func botDefenderDidUpdateHeaders(headers: [String : String], forAppId appId: String) {
        print("HUMAN Headers were updated")
    }
    
    // MARK: - singleton
    
    static let shared = HumanManager()
    
    // MARK: - properties
    
    internal let pxAppId = "PXj9y4Q8Em"
    internal let challengeOnWindow = false
    private var didSimulateBlock = false
    
    // MARK: - HUMAN
    
    func start() {
        print("SDK version: \(HumanSecurity.sdkVersion())")
        
        start(appId: pxAppId)
        setCustomParameters()
    }
    
    private func start(appId: String) {
        // Create and config the policy //
        let policy = HSPolicy()
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
            try HumanSecurity.BD.setCustomParameters(parameters: customParameters, forAppId: nil)
        }
        catch {
            print("error: \(error)")
        }
    }
}
