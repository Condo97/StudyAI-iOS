//
//  Assistant.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/26/24.
//

//import Foundation
//import UIKit
//
//struct Assistant {
//    
//    var name: String
//    var modelName: String
//    var systemPrompt: String?
//    
//    var emoji: String?
//    var image: UIImage?
//    var faceStyle: FaceStyles?
//    
//}

import UIKit

extension Assistant {
    
    var faceStyle: FaceStyles? {
        if let faceStyleID = faceStyleID {
            return FaceStyles.from(id: faceStyleID)
        }
        
        return nil
    }
    
//    var model: GPTModels? {
//        if let modelName = modelName {
//            return GPTModels(rawValue: modelName)
//        }
//        
//        return nil
//    }
    
//    var isPremium: Bool {
//        if let model = model {
//            if GPTModelTierSpecification.paidModels.contains(where: {$0 == model}) {
//                return true
//            }
//        }
//        
//        return false
//    }
    
    var uiImage: UIImage? {
        // Unwrap imagePath
        if let imagePath = imagePath {
            do {
                // Get from DocumentSaver
                return try DocumentSaver.getImage(from: imagePath)
            } catch {
                // Print and return nil TODO: Handle Errors if Necessary
                print("Error loading image in Assistant+ComputedValues... \(error)")
                return nil
            }
        }
        
        return nil
    }
    
}
