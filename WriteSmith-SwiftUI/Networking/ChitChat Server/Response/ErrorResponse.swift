//
//  ErrorResponse.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/30/24.
//

import Foundation


struct ErrorResponse: Codable {
    
    var body: String?
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
