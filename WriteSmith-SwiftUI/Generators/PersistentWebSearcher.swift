//
//  PersistentWebSearcher.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import CoreData
import Foundation

class PersistentWebSearcher {
    
    static let searchLimit = 5
    
    static func searchAndSave(authToken: String, webSearch: WebSearch, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap query, otherwise return
        guard let query = webSearch.query else {
            // TODO: Handle Errors
            print("Could not unwrap webSearch query in PersistentWebSearcher!")
            return
        }
        
        // Get and reutrn google search results
        let searchResults = try await GoogleSearcher.search(
            authToken: authToken,
            query: query)
        
        // Limit searchResults
        let limitedSearchResults = searchResults.prefix(searchLimit)
        
        await withThrowingTaskGroup(of: Void.self) { group in
            // Create WebSearchResults in CoreData adding to WebSearch
            for responseWebSearchResult in limitedSearchResults {
                // Ensure unwarap url as URL from googleSearchResult url, otherwise continue
                guard let url = URL(string: responseWebSearchResult.url) else {
                    // TODO: Handle Errors
                    print("Could not unwrap created URL from googleSearchResult url in PersistentWebSearcher!")
                    continue
                }
                
                // Add task to group
                group.addTask {
                    // Get page text for googleSearchResult, othwerise continue
                    let pageText: String
                    do {
                        guard let tempPageText = try await WebpageTextReader.getWebpageText(externalURL: url) else {
                            // TODO: Handle Errors
                            print("Could not unwrap tempPageText from getting webpage text in PersistentWebSearcher!")
                            return
                        }
                        
                        pageText = tempPageText
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error getting webpage text in PersistentWebSearcher... \(error)")
                        return
                    }
                    
                    // Create webSearchResult
                    await managedContext.perform {
                        let webSearchResult = WebSearchResult(context: managedContext)
                        webSearchResult.content = pageText
                        webSearchResult.title = responseWebSearchResult.title
                        webSearchResult.url = responseWebSearchResult.url
                        webSearchResult.webSearch = webSearch
                    }
                }
            }
        }
        
        try await managedContext.perform {
            try managedContext.save()
        }
    }
    
}
