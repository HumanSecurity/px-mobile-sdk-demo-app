//
//  HumanDemoApp.swift
//  HumanDemo
//
//  Created by Oren Yaar on 20/05/2024.
//

import SwiftUI
import HUMAN

@main
struct HumanDemoApp: App {
    
    static var shouldRestoreMainWindow = false
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.openWindow) private var openWindow
    
    @Environment(\.openWindow) private var openHumanChallengeWindow
    @Environment(\.dismissWindow) private var dismissHumanChallengeWindow
    
    init() {
        HumanManager.shared.start()
    }
    
    var body: some Scene {
        WindowGroup (id: "MainWindow") {
            ContentView()
                .onDisappear() {
                    HumanDemoApp.shouldRestoreMainWindow = true
                }
        }
        
        WindowGroup(id: HSChallengeViewModel.name) {
            HSChallengeView()
        }
        .defaultSize(width: HSChallengeViewModel.width,
                     height: HSChallengeViewModel.height, depth: 0)
        .onChange(of: HSChallengeViewModel.shared.showChallenge, {
            if (HSChallengeViewModel.shared.showChallenge) {
                openHumanChallengeWindow(id: HSChallengeViewModel.name)
            }
            else {
                dismissHumanChallengeWindow(id: HSChallengeViewModel.name)
            }
        })
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && HumanDemoApp.shouldRestoreMainWindow {
                HumanDemoApp.shouldRestoreMainWindow = false
                openWindow(id: "MainWindow")
            }
        }
        
        WindowGroup(id: HSDoctorAppViewModel.name) {
            HSDoctorAppView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: HSDoctorAppViewModel.width,
                     height: HSDoctorAppViewModel.height, depth: 0)
        .onChange(of: HSDoctorAppViewModel.shared.showDoctor, {
            if (HSDoctorAppViewModel.shared.showDoctor) {
                openHumanChallengeWindow(id: HSDoctorAppViewModel.name)
            }
            else {
                dismissHumanChallengeWindow(id: HSDoctorAppViewModel.name)
            }
        })
    }
}
