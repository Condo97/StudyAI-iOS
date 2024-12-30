//
//  GPTPromptedImageGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import Foundation


class GPTPromptedImageGenerator {
    
    static func generateGPTPromptedImageData(authToken: String, chats: [(role: CompletionRole, message: String)]) async throws -> Data? {
        // Generate image prompt
        let imagePrompt = try await ImagePromptGenerator.generateImagePrompt(
            authToken: authToken,
            chats: chats)
        
        // Generate and return imageData
        return try await ImageGenerator.generateImageData(
            authToken: authToken,
            prompt: imagePrompt)
    }
    
}
