//
//  ExploreChatGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/24/23.
//

import CoreData
import Foundation
import UIKit

class SimpleChatGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isGenerating: Bool = false
    
    @Published var generatedTexts: [Int: String] = [:]
    
    private var canGenerate = true
    
    private let maxFreeCharacters: Int = Constants.Additional.freeResponseCharacterLimit
    
    private var total_updates = 0
    
    private var updaetChatUpdateCooldown: Int {
        Int.random(in: 4...7)
    }
    
    
//    func addChat(message: String, sender: Sender, to conversationObjectID: NSManagedObjectID) async throws {
//        // TODO: Do I have to get the permanent object ID for conversationObjectID
//        try await ChatCDHelper.appendChat(
//            sender: sender,
//            text: message,
//            to: conversationObjectID)
//    }
    
    func generate(input: String, image: UIImage?, imageURL: String?, isPremium: Bool) async throws {
        // Ensure can generate, which is a variable
        guard canGenerate else {
            return
        }
        
        // Defer setting canGenerate to true and isLoading and isGenerating to false to ensure they are set to false when this method completes
        defer {
            canGenerate = true
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.isGenerating = false
            }
        }
        
        // Set canGenerate to false since it will be generating a chat
        canGenerate = false
        
        await MainActor.run {
            // Set isLoading to true
            self.isLoading = true
        }
        
        // Get selected model
        let selectedModel = GPTModelHelper.currentChatModel
        
        // Ensure authToken, otherwise return
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: Handle errors
            print("Error ensureing AuthToken in SimpleChatGenerator... \(error)")
            return
        }
        
        // Build userMessageContent
        var userMessageContent: [OAIChatCompletionRequestMessageContentType] = []
        userMessageContent.append(.text(OAIChatCompletionRequestMessageContentText(text: input)))
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let imageDataString = "data:image/jpeg;base64,\(imageData.base64EncodedString())"
            userMessageContent.append(.imageURL(OAIChatCompletionRequestMessageContentImageURL(
                imageURL: OAIChatCompletionRequestMessageContentImageURL.ImageURL(
                    url: imageDataString,
                    detail: .auto))))
        }
        
        // Build GetChatRequest
        let getChatRequest: GetChatRequest = GetChatRequest(
            authToken: authToken,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: selectedModel.rawValue,
                stream: true,
                messages: [
                    OAIChatCompletionRequestMessage(
                        role: .user,
                        content: userMessageContent)
                ]))
        
        // Get generatedText id
        let generatedTextID = generatedTexts.keys.max() ?? 0
        
        // Create stream values
        var fullResponseContent: String = ""
        var reachedMaxFreeCharacters: Bool = false
        
        // Stream
        let chatGenerator = ChatGenerator()
        do {
            try await chatGenerator.streamChat(
                getChatRequest: getChatRequest,
                stream: { getChatResponse in
                    // If isGenerating is false set to true
                    if !isGenerating {
                        await MainActor.run {
                            isGenerating = true
                        }
                    }
                    
                    // Ensure unwrap responseContent as first choice response delta content, otherwise return
                    guard let responseContent = getChatResponse.body.oaiResponse.choices[safe: 0]?.delta.content else {
                        return
                    }
                    
                    // If user is not premium and outputString is longer than maxFreeCharacters set reachedMaxFreeCharacters to true and return
                    if !isPremium && responseContent.count > maxFreeCharacters {
                        reachedMaxFreeCharacters = true
                        return
                    }
                    
                    // Append responseContent to fullResponseContent
                    fullResponseContent += responseContent
                    
                    // Update total_updates and chat if cooldown is reached
                    await MainActor.run {
                        total_updates += 1
                    }
                    
                    // If cooldown is reached update generatedText
                    if total_updates % updaetChatUpdateCooldown == 0 {
                        await MainActor.run { [fullResponseContent] in
                            self.generatedTexts[generatedTextID] = fullResponseContent
                        }
                    }
                })
        } catch {
            // TODO: Handle Errors
            print("Error streaming chat in SimpleChatGenerator, though this may be normal, continuing... \(error)")
        }
        
        // Update generatedText with fullOutputString since generation has finished
        await MainActor.run { [fullResponseContent] in
            self.generatedTexts[generatedTextID] = fullResponseContent
        }
        
        // Ensure first message has been generated, otherwise return before saving context
        guard !fullResponseContent.isEmpty else {
            // TODO: Handle errors
            throw ChatGeneratorError.nothingFromServer
        }
        
        // Add additional text if reachedMaxFreeCharacters
        if reachedMaxFreeCharacters {
            await MainActor.run {
                self.generatedTexts[generatedTextID] = self.generatedTexts[generatedTextID] ?? "" + Constants.lengthFinishReasonAdditionalText
            }
        }
    }
    
}

