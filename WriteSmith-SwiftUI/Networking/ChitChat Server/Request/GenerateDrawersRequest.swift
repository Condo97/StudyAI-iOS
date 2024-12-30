//
//  GenerateDrawersRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import Foundation

struct GenerateDrawersRequest: Codable {
    
    var authToken: String
    var input: String
    var imageData: Data?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case input
        case imageData
    }
    
}
