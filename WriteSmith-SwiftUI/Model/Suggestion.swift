//
//  Suggestion.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/4/24.
//

import Foundation
import SwiftUI

struct Suggestion: Identifiable, Equatable {
    
    var id = UUID()
    
    var symbol: LocalizedStringKey?
    var topPart: String?
    var bottomPart: String?
    
    var prompt: String?
    
    var requestsFlashCards: Bool = false
    var requestsImageSend: Bool = false
    var requestsImageGeneration: Bool = false
    
}

extension Suggestion {
    
    var fullPromptString: String {
        if let prompt = prompt {
            return prompt
        } else if let symbol = symbol {
            return "\(symbol)"
        } else {
            return (topPart ?? "") + " " + (bottomPart ?? "")
        }
    }
    
}
