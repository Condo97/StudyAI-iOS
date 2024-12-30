//
//  AICodingHelperServerNetworkClient.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation
import SwiftUI


class ChatGenerator {
    
    private let chatStream: SocketStream
    
    init() {
        // Get stream
        chatStream = ChatWebSocketConnector.getChatStream()
    }
    
    func cancel() async throws {
        try await chatStream.cancel()
    }
    
    func streamChat(authToken: String, model: GPTModels, responseFormat: ResponseFormatType, systemMessage: String?, userInputs: [String], stream: (GetChatResponse) async -> Void) async throws {
        // Create messages and add messages
        var messages: [OAIChatCompletionRequestMessage] = []
        
        // Add systemMessage if not nil
        if let systemMessage = systemMessage {
            messages.append(OAIChatCompletionRequestMessage(
                role: .system,
                content: [.text(OAIChatCompletionRequestMessageContentText(text: systemMessage))]))
        }
        
        // Add userInputs messages
        for userInput in userInputs {
            messages.append(OAIChatCompletionRequestMessage(
                role: .user,
                content: [.text(OAIChatCompletionRequestMessageContentText(text: userInput))]))
        }
        
        // Create getChatRequest
        let getChatRequest = GetChatRequest(
            authToken: authToken,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: model.rawValue,
                responseFormat: OAIChatCompletionRequestResponseFormat(type: .text),
                stream: true,
                messages: messages.reversed()))
        
        // Stream chat
        try await streamChat(getChatRequest: getChatRequest, stream: stream)
    }
    
    func streamChat(getChatRequest: GetChatRequest, stream: (GetChatResponse) async -> Void) async throws {
        // Encode getChatRequest to string, otherwise return
        guard let requestString = String(data: try JSONEncoder().encode(getChatRequest), encoding: .utf8) else {
            // TODO: Handle Errors
            print("Could not unwrap encoded getChatRequest to String in AICodingHelperServerNetworkClient!")
            return
        }
        
        // Send GetChatRequest to stream
        try await chatStream.send(.string(requestString))
        
        // Parse stream response
        do {
            for try await message in chatStream {
                // Parse message, and if it cannot be unwrapped continue
                guard let messageData = {
                    switch message {
                    case .data(let data):
                        return data
                    case .string(let string):
                        return string.data(using: .utf8)
                    @unknown default:
                        print("Message wasn't stirng or data when parsing message stream! :O")
                        return nil
                    }
                }() else {
                    print("Could not unwrap messageData in message stream! Skipping...")
                    continue
                }
                
                // Parse message to GetChatResponse
                let getChatResponse: GetChatResponse
                do {
                    getChatResponse = try JSONDecoder().decode(GetChatResponse.self, from: messageData)
                } catch {
                    print("Error decoding messageData to GetChatResponse so skipping... \(error)")
                    
                    // Catch as ErrorResponse
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: messageData)
                    
                    if errorResponse.success == 5 {
                        // Regenerate authToken
                        Task {
                            do {
                                try await AuthHelper.regenerate()
                            } catch {
                                print("Error regenerating authToken in HTTPSConnector... \(error)")
                            }
                        }
                    } else if errorResponse.success == 60 {
                        // Decode to OAIErrorResponse from errorResponse body data and throw correct GenerationError for the error received
                        if let errorResponseBodyData = errorResponse.body.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{") ? ($0.hasSuffix("}}") ? $0 : $0 + "}") : "{" + $0 + ( $0.hasSuffix("}") ? "}" : "}}") })?.data(using: .utf8) {
                            let oaiErrorResponse: OAIErrorResponse
                            do {
                                oaiErrorResponse = try JSONDecoder().decode(OAIErrorResponse.self, from: errorResponseBodyData)
                            } catch {
                                print("Error decoding to oaiErrorResponse in ChatGenerator... \(error)")
                                throw ChatGeneratorError._unreadableErrorResponse
                            }
                            
                            if oaiErrorResponse.error.code == .string_above_max_length {
                                throw ChatGeneratorError.stringAboveMaxLength
                            }
                        }
                        
                        // Otherwise throw _unreadableErrorResponse
                        throw ChatGeneratorError._unreadableErrorResponse
                    }
                    continue
                }
                
                await stream(getChatResponse)
                
//                // Update streamingChat and streamingChatDelta
//                await MainActor.run {
//                    if let zeroIndexChoice = getChatResponse.body.oaiResponse.choices[safe: 0],
//                       let content = zeroIndexChoice.delta.content {
//                        if streamingChat == nil {
//                            streamingChat = content
//                        } else {
//                            streamingChat! += content
//                        }
//                        
//                        streamingChatDelta = content
//                    }
//                }
            }
        } catch let error as NSError {
            if error.domain == NSPOSIXErrorDomain && error.code == 57 {
                // TODO: Handle Errors, though this may be normal
                print("Error parsing stream response in AICodingHelperNetworkClient... \(error)")
            }
            
            throw error
        }
    }
    
}
