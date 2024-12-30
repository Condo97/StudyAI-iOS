//
//  PersistentGPTWebSearchGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import CoreData
import Foundation

class PersistentGPTWebSearchGenerator {
    
    static func generateSaveWebSearch(authToken: String, input: [(role: CompletionRole, message: String)], to chat: Chat, in managedContext: NSManagedObjectContext) async throws {
        // Generate web search query
        let query = try await WebSearchQueryGenerator.generateWebSearchQuery(
            authToken: authToken,
            chats: input)
        
        // Create WebSearch and add to chat
        try await managedContext.perform {
            let webSearch = WebSearch(context: managedContext)
            webSearch.query = query
            webSearch.chat = chat
            
            try managedContext.save()
        }
    }
    
}
