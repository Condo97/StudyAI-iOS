//
//  ActionCollectionCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import CoreData
import Foundation

class ActionCollectionCDHelper {
    
    static func createActionCollection(actionCollectionID: String, title: String, to conversation: Conversation, in managedContext: NSManagedObjectContext) async throws -> ActionCollection {
        try await managedContext.perform {
            // Create ActionCollection in managedContext
            let actionCollection = ActionCollection(context: managedContext)
            
            // Get current date for actionCollection
            let date = Date()
            
            // Update actionCollection values
            actionCollection.actionCollectionID = actionCollectionID
            actionCollection.title = title
            actionCollection.conversation = conversation
            
            actionCollection.date = date
            
            // Save managedContext
            try managedContext.save()
            
            // Return actionCollection
            return actionCollection
        }
    }
    
    static func update(displayText: String, for actionCollection: ActionCollection, in managedContext: NSManagedObjectContext) throws {
        try managedContext.performAndWait {
            actionCollection.displayText = displayText
            
            try managedContext.save()
        }
    }
    
}
