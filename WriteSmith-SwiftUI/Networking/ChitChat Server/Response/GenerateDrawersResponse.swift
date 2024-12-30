//
//  GenerateDrawersResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import Foundation

struct GenerateDrawersResponse: Codable {
    
    struct Body: Codable {
        
        struct Drawer: Codable {
            
            var index: Int
            var title: String
            var content: String
            
            enum CodingKeys: String, CodingKey {
                case index
                case title
                case content
            }
            
        }
        
        var title: String
        var drawers: [Drawer]
        
        enum CodingKeys: String, CodingKey {
            case title
            case drawers
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
