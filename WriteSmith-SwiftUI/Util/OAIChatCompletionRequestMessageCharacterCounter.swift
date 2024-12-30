//
//  OAIChatCompletionRequestMessageCharacterCounter.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/9/24.
//

import Foundation

class OAIChatCompletionRequestMessageCharacterCounter {
    
    static let imageCharacterLength = 800
    
    static func countCharacters(in message: OAIChatCompletionRequestMessage) -> Int {
        var characterCount = 0
        for content in message.content {
            switch content {
            case .text(let oaiChatCompletionRequestMessageContentText):
                characterCount += oaiChatCompletionRequestMessageContentText.text.count
            case .imageURL(let oaiChatCompletionRequestMessageContentImageURL):
                characterCount += imageCharacterLength
            }
        }
        return characterCount
    }
    
}
