//
//  FunctionCallRequest.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation

struct FunctionCallRequest: Codable {
    
    let authToken: String
    let model: GPTModels
    let messages: [OAIChatCompletionRequestMessage]
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case model
        case messages
    }
    
}
