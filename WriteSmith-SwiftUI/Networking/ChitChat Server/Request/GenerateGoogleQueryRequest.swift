//
//  GenerateGoogleQueryRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 5/4/24.
//

import Foundation

struct GenerateGoogleQueryRequest: Codable {
    
    struct InputChat: Codable {
        
        var role: CompletionRole
        var input: String
        
        enum CodingKeys: String, CodingKey {
            case role
            case input
        }
        
    }
    
    var authToken: String
    var inputs: [InputChat]
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case inputs
    }
    
}
