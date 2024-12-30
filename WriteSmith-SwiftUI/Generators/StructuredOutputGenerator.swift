//
//  StructuredOutputGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import Foundation

class StructuredOutputGenerator {
    
    static func generate<T: Codable>(structuredOutputRequest: StructuredOutputRequest, endpoint: String) async throws -> T? {
        // Get flash cards response
        let soResponse: StructuredOutputResponse<T> = try await ChitChatHTTPSConnector.structuredOutputRequest(
            endpoint: endpoint,
            request: structuredOutputRequest)
        
        return soResponse.body.response
        
//        // Ensure unwrap first response message content and first response message content data
//        guard let firstResponseMessageContent = soResponse.body.response.choices[safe:0]?.message.content,
//              let firstResponseMessageContentData = firstResponseMessageContent.data(using: .utf8) else {
//            // TODO: Handle Errors
//            print("Could not unwrap first response message content in StructuredOutputGenerator!")
//            return nil
//        }
        
//        // Transform to FlashCardsFC and return
//        return try JSONDecoder().decode(T.self, from: firstResponseMessageContentData)
    }
    
}
