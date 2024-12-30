//
//  FlashCardCollectionCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/13/24.
//

import CoreData
import Foundation

class FlashCardCollectionCDHelper {
    
    @discardableResult
    static func createFlashCardCollection(in managedContext: NSManagedObjectContext) async throws -> FlashCardCollection {
        try await managedContext.perform {
            let flashCardCollection = FlashCardCollection(context: managedContext)
            
//            flashCardCollection.title = title
            
            try managedContext.save()
            
            return flashCardCollection
        }
    }
    
    static func deleteFlashCards(flashCardCollection: FlashCardCollection, in managedContext: NSManagedObjectContext) async throws {
        let fetchRequest = FlashCard.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(FlashCard.flashCardCollection), flashCardCollection)
        
        try await managedContext.perform {
            for flashCard in try managedContext.fetch(fetchRequest) {
                managedContext.delete(flashCard)
            }
            
            try managedContext.save()
        }
    }
    
}
