//
//  ConversationPersistentFlashCardGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import CoreData
import Foundation

class ConversationPersistentFlashCardPersistentAttachmentGenerator {
    
    // TODO: Is this abstracting things too much so that it is complicating things or is this a better way to do this hm
    @discardableResult
    static func generateSaveAddFlashCardCollectionPersistentAttachment(structuredOutputRequest: StructuredOutputRequest, to conversation: Conversation, in managedContext: NSManagedObjectContext) async throws -> PersistentAttachment? {
        // Ensure unwrap persistentAttachment from PersistentFlashCardPersistentAttachmentGenerator, otherwise return nil
        guard let persistentAttachment = try await PersistentFlashCardPersistentAttachmentGenerator.generateSaveFlashCardPersistentAttachment(
            structuredOutputRequest: structuredOutputRequest,
            in: managedContext) else {
            // TODO: Handle Errors
            print("Could not unwrap persistent attachment in ConversationPersistentAttachmentPersistentFlashCardGenerator!")
            return nil
        }
        
        // Set persistentAttachment Conversation and save and return persistentAttachment
        try await managedContext.perform {
            persistentAttachment.conversation = conversation
            
            try managedContext.save()
        }
        
        return persistentAttachment
    }
    
}
