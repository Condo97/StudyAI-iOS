//
//  GenerateGoogleQueryResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 5/4/24.
//

import Foundation

struct GenerateGoogleQueryResponse: Codable {
    
    struct Body: Codable {
        
        var query: String
        
        enum CodingKeys: String, CodingKey {
            case query
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
