//
//  ConstantsUpdater+Setup.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/3/24.
//

import Foundation

extension ConstantsUpdater {
    
    static var constantsSetupCompleteLatestVersion: Double {
        get {
            UserDefaults.standard.double(forKey: Constants.UserDefaults.constantsSetupCompleteLatestVersion)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.constantsSetupCompleteLatestVersion)
        }
    }
    
    static func setup(version: Double) {
        // Ensure constants setup complete latest version does not equal current version, otherwise return
        guard version != constantsSetupCompleteLatestVersion else {
            return
        }
        
        // Setup initial constants
        liveSpeechSilenceDuration = 1.5
        
        // Set constantsSetupCompleteLatestVersion to version
        constantsSetupCompleteLatestVersion = version
    }
    
}
