//
//  ConversationFlashCardCollectionGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import CoreData
import Foundation

class ConversationFlashCardCollectionGenerator {
    
//    func generateFlashCards(promptText: String?, promptImageData: String?) {
//        // Generate flash cards
//        Task {
//            do {
//                try await generateFlashCards(
//                    promptText: promptText,
//                    promptImageData: promptImageData,
//                    to: conversation,
//                    in: viewContext)
//            } catch {
//                // TODO: Handle Errors
//                print("Error generating flash cards in ConversationFlashCardCreatorView... \(error)")
//                return
//            }
//        }
//    }
    
    static func generateFlashCards(authToken: String, promptText: String?, promptImageData: String?, to conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        // Craete messages
        let messages: [OAIChatCompletionRequestMessage] = {
            var messageContent: [OAIChatCompletionRequestMessageContentType] = []
            if let promptText = promptText {
                messageContent.append(
                    .text(OAIChatCompletionRequestMessageContentText(text: promptText))
                )
            }
            if let promptImageData = promptImageData {
                let imageDataString = "data:image/jpeg;base64,\(promptImageData)"
                messageContent.append(
                    .imageURL(OAIChatCompletionRequestMessageContentImageURL(
                        imageURL: OAIChatCompletionRequestMessageContentImageURL.ImageURL(
                            url: imageDataString,
                            detail: .auto)))
                )
            }
            return [
                OAIChatCompletionRequestMessage(
                    role: .user,
                    content: messageContent)
            ]
        }()
        
        try await generateFlashCards(
            authToken: authToken,
            messages: messages,
            to: conversation,
            in: managedContext)
    }
    
    static func generateFlashCards(authToken: String, messages: [OAIChatCompletionRequestMessage], to conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        // Create StructuredOutputRequest
        let soRequest = StructuredOutputRequest(
            authToken: authToken,
            model: .gpt4oMini,
            messages: messages)
        
        // Generate save add flash card colletion persistent attachment to conversation
        try await ConversationPersistentFlashCardPersistentAttachmentGenerator.generateSaveAddFlashCardCollectionPersistentAttachment(
            structuredOutputRequest: soRequest,
            to: conversation,
            in: managedContext)
    }
    
}
