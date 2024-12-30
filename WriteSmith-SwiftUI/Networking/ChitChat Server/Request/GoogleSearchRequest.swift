//
//  GoogleSearchRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 5/4/24.
//

import Foundation

struct GoogleSearchRequest: Codable {
    
    var authToken: String
    var query: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case query
    }
    
}
