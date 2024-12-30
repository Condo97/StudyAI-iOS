//
//  ClassifyChatResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/12/24.
//

import Foundation

struct ClassifyChatResponse: Codable {
    
    struct Body: Codable {
        
        var wantsImageGeneration: Bool
        var wantsWebSearch: Bool
        
        enum CodingKeys: String, CodingKey {
            case wantsImageGeneration
            case wantsWebSearch
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
