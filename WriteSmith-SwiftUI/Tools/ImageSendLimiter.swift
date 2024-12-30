//
//  ImageSendLimiter.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/4/24.
//  Updated to support multiple images at a time.
//
//

import Foundation

class ImageSendLimiter {
    
    private static let maxFreeImages = -1
    private static let maxPremiumImages = -1 // -1 indicates unlimited images for premium users
    
    private static let userDefaultsTotalImagesSentKey = "totalImagesSent_iuqweiqowieu323"
    
    private static var totalImagesSent: Int {
        get {
            UserDefaults.standard.integer(forKey: userDefaultsTotalImagesSentKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsTotalImagesSentKey)
        }
    }
    
    static func increment(by count: Int = 1) {
        totalImagesSent += count
    }
    
    static func get() -> Int {
        totalImagesSent
    }
    
    static func canSendImages(isPremium: Bool, count: Int = 1) -> Bool {
        if isPremium {
            if maxPremiumImages == -1 {
                return true
            }
            return totalImagesSent + count <= maxPremiumImages
        } else {
            if maxFreeImages == -1 {
                return true
            }
            return totalImagesSent + count <= maxFreeImages
        }
    }
}
