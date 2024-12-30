//
//  GenerateSpeechRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/23/24.
//

import Foundation
import OpenAI

struct GenerateSpeechRequest: Codable {
    
    enum ResponseFormat: String, Codable {
        
        case mp3 = "mp3"
        
    }
    
    var authToken: String
    var input: String
    var voice: Session.Voice // SpeechVoice
    var responseFormat: ResponseFormat?
    var speed: Double?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case input
        case voice
        case responseFormat
        case speed
    }
    
}
