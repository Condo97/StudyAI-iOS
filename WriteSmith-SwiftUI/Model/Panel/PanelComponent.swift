//
//  PanelComponent.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

struct PanelComponent: PanelComponentProtocol {
    
    var id = UUID()
    
    var componentID: String
    var content: PanelComponentContentType
    var titleText: String
    var detailTitle: String?
    var detailText: String?
    var promptPrefix: String?
    var required: Bool?
    
    var input: String = ""
    var finalizedPrompt: String?
    var persistentAttachments: [PersistentAttachment] = []
    
    
    enum CodingKeys: String, CodingKey {
        case componentID = "id"
        case content
        case titleText
        case detailTitle
        case detailText
        case promptPrefix
        case required
    }
    
    
    private enum PanelComponentTypeIdentifiers: String {
        case dropdown = "dropdown"
        case textField = "textField"
    }
    
}

extension PanelComponent {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.titleText = try container.decode(String.self, forKey: .titleText)
        self.detailTitle = try container.decodeIfPresent(String.self, forKey: .detailTitle)
        self.detailText = try container.decodeIfPresent(String.self, forKey: .detailText)
        self.promptPrefix = try container.decodeIfPresent(String.self, forKey: .promptPrefix)
        self.required = try container.decodeIfPresent(Bool.self, forKey: .required)
        
        let contentString = try container.decodeIfPresent(String.self, forKey: .content)
        switch contentString?.lowercased() {
        case PanelComponentTypeIdentifiers.dropdown.rawValue.lowercased():
            content = .dropdown(try DropdownPanelComponentContent(from: decoder))
        case PanelComponentTypeIdentifiers.textField.rawValue.lowercased():
            content = .textField(try TextFieldPanelComponentContent(from: decoder))
        default:
            throw DecodingError.valueNotFound(PanelComponentContentType.self, DecodingError.Context(codingPath: [CodingKeys.content], debugDescription: "Could not find a valid value for \"type\" in the JSON. Please check your spelling and make sure you are using a valid type name."))
        }
        
        if let tempComponentID = try container.decodeIfPresent(String.self, forKey: .componentID) {
            self.componentID = tempComponentID
        } else {
            self.componentID = PanelComponent.generateID(
                title: titleText,
                detailTitle: detailTitle,
                detailText: detailText,
                promptPrefix: promptPrefix,
                required: required)
        }
    }
    
    private static func generateID(title: String?, detailTitle: String?, detailText: String?, promptPrefix: String?, required: Bool?) -> String {
        (title ?? "")
        +
        (detailTitle ?? "")
        +
        (detailText ?? "")
        +
        (promptPrefix ?? "")
        +
        ((required ?? false) ? "t" : "f")
    }
    
}
