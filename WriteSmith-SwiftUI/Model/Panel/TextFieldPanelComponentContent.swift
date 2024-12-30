//
//  TextFieldPanelComponentContent.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

struct TextFieldPanelComponentContent: PanelComponentContentProtocol {
    
    var id = UUID()
    
    var placeholder: String?
    var multiline: Bool?
    
    enum CodingKeys: String, CodingKey {
        case placeholder
        case multiline
    }
    
    
    private let defaultPlaceholder: String = "Tap to start typing..."
    private let defaultMultiline: Bool = false
    
    var placeholderUnwrapped: String {
        placeholder ?? defaultPlaceholder
    }
    
    var multilineUnwrapped: Bool {
        get {
            multiline ?? defaultMultiline
        }
        set {
            multiline = newValue
        }
    }
    
}
