//
//  GeneratedDrawerCollectionCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/19/24.
//

import CoreData
import Foundation

class GeneratedDrawerCollectionCDHelper {
    
    static func create(title: String, in managedContext: NSManagedObjectContext) async throws -> GeneratedDrawerCollection {
        return try await managedContext.perform {
            // Create, save, and return GeneratedDrawerCollection and set title and titleOriginal
            let generatedDrawerCollection = GeneratedDrawerCollection(context: managedContext)
            generatedDrawerCollection.title = title
            generatedDrawerCollection.titleOriginal = title
            
            try managedContext.save()
            
            return generatedDrawerCollection
        }
    }
    
}
