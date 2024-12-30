//
//  GoogleSearcher.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import Foundation

class GoogleSearcher {
    
    static func search(authToken: String, query: String) async throws -> [(title: String, url: String)] {
        // Build request
        let googleSearchRequest = GoogleSearchRequest(
            authToken: authToken,
            query: query)
        
        // Get response
        let googleSearchResponse = try await ChitChatHTTPSConnector.googleSearch(request: googleSearchRequest)
        
        // Transform results to return format and return
        return googleSearchResponse.body.results.map({(title: $0.title, url: $0.url)})
    }
    
}
