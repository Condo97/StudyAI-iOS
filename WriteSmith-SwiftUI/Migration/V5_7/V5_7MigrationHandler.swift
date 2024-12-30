//
//  V5_7MigrationHandler.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/25/24.
//

import CoreData
import Foundation

class V5_7MigrationHandler {
    
    static func migrate(in managedContext: NSManagedObjectContext) throws {
        // Update featured Assistant faceAssistantName to faceAssistantID
        try managedContext.performAndWait {
            // Get featured Assistants
            let featuredAssistantsFetchRequest = Assistant.fetchRequest()
            featuredAssistantsFetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(Assistant.featured), true)
            
            let results = try managedContext.fetch(featuredAssistantsFetchRequest)
            
            // Loop though and update Assistants
            for result in results {
                // If Assistant faceStyleName is not nil nor empty get the associated FaceStyle and update its faceStyleName to nil and faceStyleID to the FaceStyle ID
                if let faceStyleName = result.faceStyleName, !faceStyleName.isEmpty {
                    // Get faceStyle for faceStyleName from each FaceStyles nameLegacy
                    let faceStyle: FaceStyles = {
                        switch faceStyleName {
                        case FaceStyles.man.nameLegacy: .man
                        case FaceStyles.lady.nameLegacy: .lady
                        case FaceStyles.worm.nameLegacy: .worm
                        case FaceStyles.artist.nameLegacy: .artist
                        case FaceStyles.genius.nameLegacy: .genius
                        case FaceStyles.pal.nameLegacy: .pal
                        default: .worm
                        }
                    }()
                    
                    // Update faceStyleName and faceStyleID
                    result.faceStyleName = nil
                    result.faceStyleID = faceStyle.id
                }
            }
            
            // Save
            try managedContext.save()
        }
    }
    
}
