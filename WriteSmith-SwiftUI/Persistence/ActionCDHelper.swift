//
//  ActionCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import CoreData
import Foundation

class ActionCDHelper {
    
    static func createAction(actionID: String, title: String, drawerCollection: GeneratedDrawerCollection? = nil, panelContent: PanelContent? = nil, to actionCollection: ActionCollection, in managedContext: NSManagedObjectContext) async throws -> Action {
        try await managedContext.perform {
            // Create action in managedContext
            let action = Action(context: managedContext)
            
            // Update action values
            action.date = Date()
            
            action.actionID = actionID
            action.title = title
            action.drawerCollection = drawerCollection
            action.panelContent = panelContent
            action.actionCollection = actionCollection
            
            // Save managedContext
            try managedContext.save()
            
            // Return action
            return action
        }
    }
    
    static func createAction(actionID: String, title: String, drawerCollection: GeneratedDrawerCollection? = nil, panelContent: PanelContent? = nil, to actionCollection: ActionCollection, in managedContext: NSManagedObjectContext) throws -> Action {
        try managedContext.performAndWait {
            // Create action in managedContext
            let action = Action(context: managedContext)
            
            // Update action values
            action.date = Date()
            
            action.actionID = actionID
            action.title = title
            action.drawerCollection = drawerCollection
            action.panelContent = panelContent
            action.actionCollection = actionCollection
            
            // Save managedContext
            try managedContext.save()
            
            // Return action
            return action
        }
    }
    
    static func updateAction(_ action: Action, drawerCollection: GeneratedDrawerCollection, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            // Update and save action drawerCollection with drawerCollection
            action.drawerCollection = drawerCollection
            
            try managedContext.save()
        }
    }
    
    static func updateAction(_ action: Action, panelContent: PanelContent, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            // Update and save action panelContent with panelContent
            action.panelContent = panelContent
            
            try managedContext.save()
        }
    }
    
}
