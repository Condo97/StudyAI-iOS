//
//  GoogleSearchResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 5/4/24.
//

import Foundation

struct GoogleSearchResponse: Codable {
    
    struct Body: Codable {
        
        struct Result: Codable {
            
            var title: String
            var url: String
            
            enum CodingKeys: String, CodingKey {
                case title
                case url
            }
            
        }
        
        var results: [Result]
        
        enum CodingKeys: String, CodingKey {
            case results
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
