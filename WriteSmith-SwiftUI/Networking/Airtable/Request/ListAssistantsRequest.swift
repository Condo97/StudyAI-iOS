//
//  ListAssistantsRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/12/24.
//

import Foundation

struct ListAssistantsRequest: Codable {
    
    let offset: String?
    
    enum CodingKeys: String, CodingKey {
        case offset
    }
    
}
