//
//  GenerateTitleResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/15/24.
//

import Foundation

struct GenerateTitleResponse: Codable {
    
    struct Body: Codable {
        
        var title: String?
        
        enum CodingKeys: String, CodingKey {
            case title
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
