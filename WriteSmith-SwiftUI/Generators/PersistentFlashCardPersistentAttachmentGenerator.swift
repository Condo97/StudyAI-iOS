//
//  PersistentFlashCardPersistentAttachmentGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import CoreData
import Foundation

class PersistentFlashCardPersistentAttachmentGenerator {
    
    static func generateSaveFlashCardPersistentAttachment(structuredOutputRequest: StructuredOutputRequest, in managedContext: NSManagedObjectContext) async throws -> PersistentAttachment? {
        // Ensure unwrap create save flash card collection, otherwise return nil
        guard let flashCardCollection = try await PersistentFlashCardCollectionGenerator.generateSaveFlashCardCollection(
            structuredOutputRequest: structuredOutputRequest,
            in: managedContext) else {
            // TODO: Handle Errors
            print("Could not unwrap flash card collection in ConversationPersistentAttachmentPersistentFlashCardGenerator!")
            return nil
        }
        
        // Create and save PersistentAttachment while updating cached text and generated title
        return try await PersistentAttachmentNetworkedPersistenceManager.createFlashCardsAttachmentUpdateCachedTextAndGeneratedTitle(
            flashCardCollection: flashCardCollection,
            title: nil,
            in: managedContext)
    }
    
}
