//
//  ConversationToOAIChatCompletionRequestMessagsAdapter.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/18/24.
//

import CoreData
import Foundation

class ConversationToOAIChatCompletionRequestMessagsAdapter {
    
    static func adapt(conversation: Conversation, in managedContext: NSManagedObjectContext, maxCharacterLimit: Int, maxWebResults: Int, maxWebResultCharacterLimit: Int) async throws -> [OAIChatCompletionRequestMessage] {
        // Get Conversation Chats
        let chatFetchRequest = Chat.fetchRequest()
//        chatFetchRequest.fetchLimit = maxChatCount
        chatFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
        chatFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: true)]
        let chats = try await managedContext.perform {
            return try managedContext.fetch(chatFetchRequest) as [Chat]
        }
        
        return try await adapt(
            chats: chats,
            in: managedContext,
            maxCharacterLimit: maxCharacterLimit,
            maxWebResults: maxWebResults,
            maxWebResultCharacterLimit: maxWebResultCharacterLimit)
    }
    
    static func adapt(chats: [Chat], in managedContext: NSManagedObjectContext, maxCharacterLimit: Int, maxWebResults: Int, maxWebResultCharacterLimit: Int) async throws -> [OAIChatCompletionRequestMessage] {
        return try await getMessages(
            for: chats,
            in: managedContext,
            maxCharacterLimit: maxCharacterLimit,
            maxWebResults: maxWebResults,
            maxWebResultCharacterLimit: maxWebResultCharacterLimit)
    }
    
    
    private static func getMessages(for chats: [Chat], in managedContext: NSManagedObjectContext, maxCharacterLimit: Int, maxWebResults: Int, maxWebResultCharacterLimit: Int) async throws -> [OAIChatCompletionRequestMessage] {
        var messages: [OAIChatCompletionRequestMessage] = []
        var totalInputCharacters: Int = 0
        for chat in chats.reversed() {
            // Create message. Messages are read by GPT starting from 0 or using the 0 as the most important so start from there
            var message = OAIChatCompletionRequestMessage(
                role: CompletionRole.from(sender: Sender(rawValue: chat.sender ?? "") ?? .user),
                content: [])
            
            if let text = chat.text {
                // Append text
                message.content.append(.text(OAIChatCompletionRequestMessageContentText(text: text)))
            }
            
            if let imageData = chat.imageData {
                // Only user chats can contain image URL per OpenAI
                if let sender = Sender(rawValue: chat.sender ?? "") {
                    let completionRole = CompletionRole.from(sender: sender)
                    if completionRole == .user {
                        // Set imageDataString to jpeg json identifier string with imageData base64 encoded string
                        let imageDataString = "data:image/jpeg;base64,\(imageData.base64EncodedString())"
                        
                        // Append imageData
                        message.content.append(.imageURL(OAIChatCompletionRequestMessageContentImageURL(
                            imageURL: OAIChatCompletionRequestMessageContentImageURL.ImageURL(
                                url: imageDataString,
                                detail: .auto))))
                    }
                }
            }
            
            if let webSearch = chat.webSearch {
                // Get webSearchResults and append their content to message
                let webSearchResultsFetchRequest = WebSearchResult.fetchRequest()
                webSearchResultsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(WebSearchResult.webSearch), webSearch)
                do {
                    let results = try await managedContext.perform {
                        try managedContext.fetch(webSearchResultsFetchRequest) as [WebSearchResult]
                    }
                    for result in results.prefix(maxWebResults) {
                        if let resultContent = result.content {
                            let trimmedResultContent = resultContent.prefix(maxWebResultCharacterLimit) // TODO: This should be done when adding it initially or it should get summarized and set also when adding initially
                            message.content.append(.text(OAIChatCompletionRequestMessageContentText(text: "\nWEB SEARCH RESULT\nURL: \(result.url ?? "")\nContent: \(trimmedResultContent)")))
                        }
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error fetching web search results in PersistentChatGenerator... \(error)")
                }
            }
            
            // If total messages character count plus message character count is less than max character length free or paid add its character count to total character count and append message to messages
            let currentMessageCharacterCount = OAIChatCompletionRequestMessageCharacterCounter.countCharacters(in: message)
            if totalInputCharacters + currentMessageCharacterCount < (maxCharacterLimit) {
                message.content = message.content.reversed()
                messages.append(message)
                totalInputCharacters += currentMessageCharacterCount
            } else {
                // TODO: Handle Errors
                print("Message not appended in PersistentChatGenerator because the sum of messages is larger than the max character length.")
                break
            }
        }
        
        return messages.reversed()
    }
    
}
