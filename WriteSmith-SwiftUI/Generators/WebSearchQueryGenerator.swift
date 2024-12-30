//
//  WebSearchQueryGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import Foundation

class WebSearchQueryGenerator {
    
    static func generateWebSearchQuery(authToken: String, chats: [(role: CompletionRole, message: String)]) async throws -> String {
        // Build request
        let generateGoogleQueryRequest = GenerateGoogleQueryRequest(
            authToken: authToken,
            inputs: chats.map({
                GenerateGoogleQueryRequest.InputChat(
                    role: $0.role,
                    input: $0.message)
            }))
        
        // Get response
        let generateGoogleQueryResponse = try await ChitChatHTTPSConnector.generateGoogleQuery(request: generateGoogleQueryRequest)
        
        // Return query
        return generateGoogleQueryResponse.body.query
    }
    
}
