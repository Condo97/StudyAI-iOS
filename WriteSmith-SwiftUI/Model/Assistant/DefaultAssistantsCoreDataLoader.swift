//
//  DefaultAssistantsCoreDataLoader.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/26/24.
//

import CoreData
import Foundation
import SwiftUI

class DefaultAssistantsCoreDataLoader {
    
    static func deleteDeviceCreatedAssistantsInCoreData(in managedContext: NSManagedObjectContext) async throws {
        let fetchRequest = Assistant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(Assistant.deviceCreated), true)
        
        try await managedContext.perform {
            let results = try managedContext.fetch(fetchRequest)
            
            for result in results {
                managedContext.delete(result)
            }
            
            try managedContext.save()
        }
    }
    
    static func deviceCreatedAssistantExists(in managedContext: NSManagedObjectContext) async throws -> Bool {
        let fetchRequest = Assistant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(Assistant.deviceCreated), true)
        
        return try await managedContext.perform {
            let results = try managedContext.fetch(fetchRequest)
            
            return results.count > 0
        }
    }
    
    static func loadDefaultAssistantsInCoreData(in managedContext: NSManagedObjectContext) async throws {
        // Load face assistants
        for assistant in DefaultAssistants.face {
            // Ensure does not exist
            do {
                guard try await !exists(deviceCreated: true, name: assistant.name, premium: assistant.premium, in: managedContext) else {
                    // Continue if it exists
                    continue
                }
            } catch {
                // Print error and continue TODO: Handle Errors if Necessary
                print("Error checking if assistant exists in DefaultAssistantsCoreDataLoader... \(error)")
                continue
            }
            
            // Save image to documents and get URI if imageName and image exist, otherwise just skip
            var imagePath: String?
            if let imageName = assistant.imageName,
               let image = UIImage(named: imageName) {
                // Set imagePath to imageName
                imagePath = imageName
                
                do {
                    // Unwrap imagePath to safely use
                    if let imagePath = imagePath {
                        // Save image to imagePath
                        try DocumentSaver.save(image, to: imagePath)
                    }
                } catch {
                    // Set imagePath to nil if there is an error saving TODO: Handle Errors
                    print("Error saving image with DocumentSaver in DefaultAssistantsCoreDataLoader... \(error)")
                    imagePath = nil
                }
            }
            
            // Create
            await managedContext.perform {
                let assistantCoreData = Assistant(context: managedContext)
                assistantCoreData.featured = true
                assistantCoreData.deviceCreated = true
                assistantCoreData.userCreated = false
                assistantCoreData.name = assistant.name
                assistantCoreData.category = assistant.category.displayName
                assistantCoreData.assistantShortDescription = assistant.shortDescription
                assistantCoreData.assistantDescription = assistant.description
                assistantCoreData.systemPrompt = assistant.systemPrompt
                assistantCoreData.initialMessage = assistant.initialMessage
                assistantCoreData.premium = assistant.premium
                assistantCoreData.emoji = assistant.emoji
                assistantCoreData.imagePath = imagePath
                assistantCoreData.faceStyleID = assistant.faceStyle?.id
                assistantCoreData.pronouns = assistant.pronouns?.name
//                assistantCoreData.displayBackgroundColorName = assistant.category.colorName
                assistantCoreData.usageMessages = assistant.usageMessages
                assistantCoreData.usageUsers = assistant.usageUsers
            }
        }
        
//        // Load other assistants
//        for assistant in DefaultAssistants.other {
//            // Ensure does not exist
//            do {
//                guard try await !exists(deviceCreated: true, name: assistant.name, premium: assistant.premium, in: managedContext) else {
//                    // Continue if it exists
//                    continue
//                }
//            } catch {
//                // Print error and continue TODO: Handle Errors if Necessary
//                print("Error checking if assistant exists in DefaultAssistantsCoreDataLoader... \(error)")
//                continue
//            }
//            
//            // Save image to documents and get URI if imageName and image exist, otherwise just skip
//            var imagePath: String?
//            if let imageName = assistant.imageName,
//               let image = UIImage(named: imageName) {
//                // Set imagePath to imageName
//                imagePath = imageName
//                
//                do {
//                    // Unwrap imagePath to safely use
//                    if let imagePath = imagePath {
//                        // Save image to imagePath
//                        try DocumentSaver.save(image, to: imagePath)
//                    }
//                } catch {
//                    // Set imagePath to nil if there is an error saving TODO: Handle Errors
//                    print("Error saving image with DocumentSaver in DefaultAssistantsCoreDataLoader... \(error)")
//                    imagePath = nil
//                }
//            }
//            
//            // Create
//            await managedContext.perform {
//                let assistantCoreData = Assistant(context: managedContext)
//                assistantCoreData.featured = false
//                assistantCoreData.deviceCreated = true
//                assistantCoreData.userCreated = false
//                assistantCoreData.name = assistant.name
//                assistantCoreData.category = assistant.category.displayName
//                assistantCoreData.assistantShortDescription = assistant.shortDescription
//                assistantCoreData.assistantDescription = assistant.description
//                assistantCoreData.systemPrompt = assistant.systemPrompt
//                assistantCoreData.initialMessage = assistant.initialMessage
//                assistantCoreData.premium = assistant.premium
//                assistantCoreData.emoji = assistant.emoji
//                assistantCoreData.imagePath = imagePath
//                assistantCoreData.faceStyleName = assistant.faceStyle?.name
//                assistantCoreData.pronouns = assistant.pronouns?.name
////                assistantCoreData.displayBackgroundColorName = assistant.category.colorName
//                assistantCoreData.usageMessages = assistant.usageMessages
//                assistantCoreData.usageUsers = assistant.usageUsers
//            }
//        }
        
        // Save managedContext
        try await managedContext.perform {
            try managedContext.save()
        }
    }
    
    private static func exists(deviceCreated: Bool, name: String, premium: Bool, in managedContext: NSManagedObjectContext) async throws -> Bool {
        let fetchRequest = Assistant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %d and %K = %@ and %K = %d", #keyPath(Assistant.deviceCreated), deviceCreated, #keyPath(Assistant.name), name, #keyPath(Assistant.premium), premium)
        
        return try await managedContext.perform {
            let results = try managedContext.fetch(fetchRequest)
            
            return results.count > 0
        }
    }
    
}
