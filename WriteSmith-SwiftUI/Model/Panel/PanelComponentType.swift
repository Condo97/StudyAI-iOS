//
//  PanelComponentType.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import Foundation

enum PanelComponentContentType: Codable, Hashable {
    
    case attachment(AttachmentPanelComponentContent)
    case textField(TextFieldPanelComponentContent)
    case dropdown(DropdownPanelComponentContent)
    
}
