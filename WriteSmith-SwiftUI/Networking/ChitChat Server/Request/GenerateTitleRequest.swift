//
//  GenerateTitleRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/15/24.
//

import Foundation

struct GenerateTitleRequest: Codable {
    
    var authToken: String
    var input: String?
    var imageData: String?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case input
        case imageData
    }
    
}
