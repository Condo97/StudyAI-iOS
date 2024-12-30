//
//  PersistentFlashCardCollectionGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import CoreData
import Foundation

class PersistentFlashCardCollectionGenerator {
    
    static func generateSaveFlashCardCollection(structuredOutputRequest: StructuredOutputRequest, in managedContext: NSManagedObjectContext) async throws -> FlashCardCollection? {
        // Ensure unwrap generate flash cards, otherwise return nil
        guard let flashCardsSO: FlashCardsSO = try await StructuredOutputGenerator.generate(
            structuredOutputRequest: structuredOutputRequest,
            endpoint: HTTPSConstants.StructuredOutput.generateFlashCards) else {
            // TODO: Handle Errors
            print("Could not unwrap flashCardsFC from StructuredOutputGenerator in PersistentFlashCardCollectionGenerator!")
            return nil
        }
        
        // Create Flash Card Collection
        let flashCardsCollection = try await FlashCardCollectionCDHelper.createFlashCardCollection(
            in: managedContext)
        
        // Create Flash Cards to Flash Card Collection
        for i in 0..<flashCardsSO.flashCards.count {
            try await FlashCardCDHelper.createFlashCard(
                index: Int64(i),
                front: flashCardsSO.flashCards[i].front,
                back: flashCardsSO.flashCards[i].back,
                to: flashCardsCollection,
                in: managedContext)
        }
        
        // Return flashCardsCollection
        return flashCardsCollection
    }
    
}
