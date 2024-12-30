//
//  PrintToConsoleRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 5/8/24.
//

import Foundation

struct PrintToConsoleRequest: Codable {
    
    var authToken: String
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case message
    }
    
}
