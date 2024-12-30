//
//  ImageGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import Foundation

class ImageGenerator {
    
    static func generateImageData(authToken: String, prompt: String) async throws -> Data? {
        // Create generate image request
        let giRequest = GenerateImageRequest(
            authToken: authToken,
            prompt: prompt)
        
        // Get generate image response from HTTPSConnector
        let giResponse = try await ChitChatHTTPSConnector.generateImage(request: giRequest)
        
        // Ensure unwrap imageData, otherwise return nil
        guard let imageData = giResponse.body.imageData else {
            // TODO: Handle Errors
            print("Could not unwrap imageData in ImageGenerator!")
            return nil
        }
        
        // Return base64Encoded imageData
        return Data(base64Encoded: imageData)
    }
    
}
