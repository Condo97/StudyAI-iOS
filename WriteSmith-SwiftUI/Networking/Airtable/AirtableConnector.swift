//
//  AirtableConnector.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/12/24.
//

import Foundation

class AirtableConnector {
    
    private static let baseID = "appukE1AJQnZNDjIh"
    private static let tableID = "tblsBXFMHiKHL0VlT"
    
    static func listAssistants(listAssistantsRequest: ListAssistantsRequest) async throws -> ListAssistantsResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(HTTPSConstants.airtable)/\(baseID)/\(tableID)\(HTTPSConstants.airtableListRecords)")!,
            body: listAssistantsRequest,
            headers: [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(Keys.airtableAPI)"
            ])
        
        let listAssistantsResponse = try JSONDecoder()
            .decode(ListAssistantsResponse.self, from: data)
        
        return listAssistantsResponse
    }
    
}
