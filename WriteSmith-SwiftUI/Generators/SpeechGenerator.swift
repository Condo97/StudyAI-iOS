//
//  SpeechGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/23/24.
//

import Foundation
import OpenAI

class SpeechGenerator {
    
//    static func generateSpeech(authToken: String, input: String) async throws -> Data {
//        try await generateSpeech(
//            authToken: authToken,
//            input: input,
//            voice: ConstantsUpdater.liveSpeechVoice)
//    }
    
    static func generateSpeech(authToken: String, input: String, speed: Double, voice: Session.Voice) async throws -> Data {
        // Create GenerateSpeechRequest
        let generateSpeechRequest = GenerateSpeechRequest(
            authToken: authToken,
            input: input,
            voice: voice,
            responseFormat: .mp3,
            speed: speed)
        
        // Get speech
        let speech = try await ChitChatHTTPSConnector.generateSpeech(request: generateSpeechRequest)
        
        do {
            try Task.checkCancellation()
        } catch {
            print("Task Cancelled")
        }
        
        // Return speech
        return speech
//        // Append speech to generatedSpeeches
//        await MainActor.run {
//            generatedSpeeches.append(speech)
//        }
    }
    
}
