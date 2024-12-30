//
//  PanelContentCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import CoreData
import Foundation

class PanelContentCDHelper {
    
    static func createPanelContent(to action: Action, in managedContext: NSManagedObjectContext) async throws -> PanelContent {
        return try await managedContext.perform {
            let panelContent = PanelContent(context: managedContext)
            panelContent.action = action
            
            try managedContext.save()
            
            return panelContent
        }
    }
    
}
