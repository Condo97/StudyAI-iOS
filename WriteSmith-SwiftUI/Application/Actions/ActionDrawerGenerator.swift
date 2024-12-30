//
//  ActionDrawerGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/19/24.
//

import CoreData
import Foundation

class ActionDrawerGenerator: DrawerGenerator {
    
    func generateDrawerCollection(actionID: String, actionTitle: String, text: String, imageData: Data?, authToken: String, to actionCollection: ActionCollection, in managedContext: NSManagedObjectContext) async throws -> Action {
        // Generate drawer collection
        let generatedDrawerCollection = try await generateDrawerCollection(
            text: text,
            imageData: imageData,
            authToken: authToken,
            in: managedContext)
        
        // Create action with actionCollection using ActionCDHelper
        return try await ActionCDHelper.createAction(
            actionID: actionID,
            title: actionTitle,
            drawerCollection: generatedDrawerCollection,
            to: actionCollection,
            in: managedContext)
    }
    
}
