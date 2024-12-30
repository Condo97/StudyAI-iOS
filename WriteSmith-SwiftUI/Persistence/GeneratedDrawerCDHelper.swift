//
//  GeneratedDrawerCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/19/24.
//

import CoreData
import Foundation

class GeneratedDrawerCDHelper {
    
    static func create(index: Int, header: String, content: String, to parentCollection: GeneratedDrawerCollection, in managedContext: NSManagedObjectContext) async throws -> GeneratedDrawer {
        return try await managedContext.perform {
            // Create, save, and return GeneratedDrawer and set index, header, headerOriginal, content, contentOriginal, and parentCollection
            let generatedDrawer = GeneratedDrawer(context: managedContext)
            generatedDrawer.index = Int64(exactly: index) ?? 0
            generatedDrawer.header = header
            generatedDrawer.headerOriginal = header
            generatedDrawer.content = content
            generatedDrawer.contentOriginal = content
            generatedDrawer.parentCollection = parentCollection
            
            try managedContext.save()
            
            return generatedDrawer
        }
    }
    
}

