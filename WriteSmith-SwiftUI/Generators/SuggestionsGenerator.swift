//
//  SuggestionsGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/19/24.
//

import CoreData
import Foundation

class SuggestionsGenerator {
    
    private static let maxChatCharacterLimit = 1000
    private static let maxChatWebResults = 3
    private static let maxChatWebResultCharacterLimit = 500
    
    static func generateSuggestions(numberOfSuggestionsToLoad: Int, numberOfChatsToUse: Int, authToken: String, for conversation: Conversation, in managedContext: NSManagedObjectContext) async throws -> [String] {
        // Get chats from conversation
        let chatsFetchRequest = Chat.fetchRequest()
        chatsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
        chatsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
        chatsFetchRequest.fetchLimit = numberOfChatsToUse
        let chats = try await managedContext.perform {
            try managedContext.fetch(chatsFetchRequest)
        }
        
        // Create messages with first message as instructions
        var messages: [OAIChatCompletionRequestMessage] = [
            OAIChatCompletionRequestMessage(
                role: .user,
                content: [
                    .text(OAIChatCompletionRequestMessageContentText(text: getPrefixChatInstructions(
                            numberOfSuggestionsToLoad: numberOfSuggestionsToLoad)))
                ])]
        
        // Append chats to messages
        messages.append(contentsOf: try await ConversationToOAIChatCompletionRequestMessagsAdapter.adapt(
            chats: chats,
            in: managedContext,
            maxCharacterLimit: maxChatCharacterLimit,
            maxWebResults: maxChatWebResults,
            maxWebResultCharacterLimit: maxChatWebResultCharacterLimit))
        
        // Create StructruedOutputRequest
        let structuredOutputRequest = StructuredOutputRequest(
            authToken: authToken,
            model: .gpt4oMini,
            messages: messages)
        
        // Get GenerateSuggestionsSO
        let generateSuggestionsSO: GenerateSuggestionsSO? = try await StructuredOutputGenerator.generate(
            structuredOutputRequest: structuredOutputRequest,
            endpoint: HTTPSConstants.StructuredOutput.generateSuggestions)
        
        // Return suggestions or if nil empty array
        return generateSuggestionsSO?.suggestions ?? []
    }
    
    
    private static func getPrefixChatInstructions(numberOfSuggestionsToLoad: Int) -> String {
        "Generate \(numberOfSuggestionsToLoad) suggestions to autofill the USER's next message. These will appear as buttons to the user, so make sure they are from the user's perspective to chat with AI. These are suggestions for the user to send to GPT."
//        "Generate \(numberOfSuggestionsToLoad) suggestions. Make them different than \(differentThan.joined(separator: ", "))" TODO: The different than functionality does not matter because all suggestions are being generated simultaneously
    }
    
}
