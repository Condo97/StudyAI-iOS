//
//  FlashCardCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/13/24.
//

import CoreData
import Foundation

class FlashCardCDHelper {
    
    @discardableResult
    static func createFlashCard(index: Int64, front: String, back: String, to flashCardCollection: FlashCardCollection, in managedContext: NSManagedObjectContext) async throws -> FlashCard {
        try await managedContext.perform {
            let flashCard = FlashCard(context: managedContext)
            
            flashCard.index = index
            flashCard.front = front
            flashCard.back = back
            flashCard.flashCardCollection = flashCardCollection
            
            return flashCard
        }
    }
    
}
