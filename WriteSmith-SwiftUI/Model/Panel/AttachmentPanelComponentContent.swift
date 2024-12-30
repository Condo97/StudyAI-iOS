//
//  AttachmentPanelComponentContent.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import Foundation

struct AttachmentPanelComponentContent: PanelComponentContentProtocol {
    
    var id = UUID()
    
    var maxAttachments: Int?
    
    enum CodingKeys: String, CodingKey {
        case maxAttachments
    }
    
}
