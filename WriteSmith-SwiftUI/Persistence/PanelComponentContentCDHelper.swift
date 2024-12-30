//
//  PanelComponentContentCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import CoreData
import Foundation

class PanelComponentContentCDHelper {
    
    static func createPanelComponentContent(componentID: String, input: String, persistentAttachments: [PersistentAttachment], to panelContent: PanelContent, in managedContext: NSManagedObjectContext) async throws -> PanelComponentContent {
        return try await managedContext.perform {
            let panelComponentContent = PanelComponentContent(context: managedContext)
            panelComponentContent.componentID = componentID
            panelComponentContent.cachedInput = input
            panelComponentContent.panelContent = panelContent
            panelComponentContent.persistentAttachments = NSSet(array: persistentAttachments) // TODO: If something's mysteriously happening it could be this lol
            
            try managedContext.save()
            
            return panelComponentContent
        }
    }
    
    static func updatePanelComponentContent(_ panelComponentContent: PanelComponentContent, withCachedInput cachedInput: String, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            panelComponentContent.cachedInput = cachedInput
            
            try managedContext.save()
        }
    }
    
}
