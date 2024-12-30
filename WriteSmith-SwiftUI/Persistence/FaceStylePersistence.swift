//
//  FaceStylePersistence.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/25/24.
//

import Foundation

class FaceStylePersistence {
    
    static var faceStyle: FaceStyles {
        get {
            FaceStyles.from(id: UserDefaults.standard.string(forKey: userDefaultsKey) ?? "")
        }
        set {
            UserDefaults.standard.set(newValue.id, forKey: userDefaultsKey)
        }
    }
    
    
    private static let userDefaultsKey = "faceStyle"
    
}
