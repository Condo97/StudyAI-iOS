//
//  ImagePromptGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import Foundation


class ImagePromptGenerator {
    
    private static let maxTokens = 500
    private static let temperature = 1.0
    private static let systemPrompt = "You are an image prompt generator. You take the user's message and transform it to a prompt to use in DALLE-3 for image generation. You are to only include the prompt in the response so that it can be used in a function."
    private static let latestMessagePrefix = "Generate a prompt for DALL-E 3 based on the user's message."
    
    static func generateImagePrompt(authToken: String, chats: [(role: CompletionRole, message: String)]) async throws -> String {
        // Create messages from chats
        var messages: [OAIChatCompletionRequestMessage] = []
        for i in 0..<chats.count {
            // Message content is either the chat message or latestMessagePrefix plus the chat message if it is the last message
            let messageContent = "\(i == chats.count - 1 ? "\(latestMessagePrefix)\n" : "")\(chats[i].message)"
            messages.append(
                OAIChatCompletionRequestMessage(
                    role: chats[i].role,
                    content: [.text(OAIChatCompletionRequestMessageContentText(text: messageContent))])
            )
        }
        
        // Create GetChatRequest
        let getChatRequest = GetChatRequest(
            authToken: authToken,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: GPTModels.gpt4oMini.rawValue,
                maxTokens: ImagePromptGenerator.maxTokens,
                temperature: temperature,
                responseFormat: OAIChatCompletionRequestResponseFormat(type: .text),
                stream: true,
                messages: messages))
        
        // Stream with ChatGenerator appending response deltas to fullResponseContent
        var fullResponseContent: String = ""
        do {
            try await ChatGenerator().streamChat(
                getChatRequest: getChatRequest,
                stream: { response in
                    if let responseContent = response.body.oaiResponse.choices[safe: 0]?.delta.content {
                        fullResponseContent += responseContent
                    }
                })
        } catch {
            // TODO: Handle Errors
            print("Error streaming chat in ImagePromptGenerator, this may be normal, continuing... \(error)")
        }
        
        // Return fullResponseContent
        return fullResponseContent
    }
    
}
