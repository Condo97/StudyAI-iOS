//
//  PanelComponentProtocol.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import Foundation

protocol PanelComponentProtocol: Identifiable, Codable, Hashable {
    
    var id: UUID { get set }
    
    var componentID: String { get set }
    var content: PanelComponentContentType { get set }
    var titleText: String { get set }
    var detailTitle: String? { get set }
    var detailText: String? { get set }
    var promptPrefix: String? { get set }
    var required: Bool? { get set }
    
    var input: String { get set }
    var finalizedPrompt: String? { get set }
    var persistentAttachments: [PersistentAttachment] { get set }
    
}

extension PanelComponentProtocol {
    
    private var defaultRequired: Bool {
        false
    }
    
    var requiredUnwrapped: Bool {
        get {
            required ?? defaultRequired
        }
        set {
            required = newValue
        }
    }
    
}
