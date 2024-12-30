//
//  AssistantCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/27/24.
//

import CoreData
import Foundation

class AssistantCDHelper {
    
    static func countChats(for assistant: Assistant, in managedContext: NSManagedObjectContext) async throws -> Int {
        // Fetch all Conversations
        let conversationFetchRequest = Conversation.fetchRequest()
        conversationFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Conversation.assistant), assistant.objectID)
        
        var conversations: [Conversation] = []
        try await managedContext.perform {
            conversations = try managedContext.fetch(conversationFetchRequest)
        }
        
        // Count all Chats in each Conversation
        var chatCount: Int = 0
        for conversation in conversations {
            let chatFetchRequest = Chat.fetchRequest()
            chatFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.objectID)
            
            try await managedContext.perform {
                chatCount += try managedContext.count(for: chatFetchRequest)
            }
        }
        
        return chatCount
    }
    
    static func getMostPopularFeaturedAssistant(in managedContext: NSManagedObjectContext) throws -> Assistant? {
        let fetchRequest = Assistant.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(Assistant.featured), true)
        
        return try managedContext.performAndWait {
            let results = try managedContext.fetch(fetchRequest)
            
            return results[safe: 0]
        }
    }
    
    static func getMostPopularFeaturedAssistant(in managedContext: NSManagedObjectContext) async throws -> Assistant? {
        let fetchRequest = Assistant.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(Assistant.featured), true)
        
        return try await managedContext.perform {
            let results = try managedContext.fetch(fetchRequest)
            
            return results[safe: 0]
        }
    }
    
}
