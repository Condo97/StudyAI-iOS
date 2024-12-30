//
//  PanelProtocol.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import Foundation

protocol PanelProtocol: Identifiable, Codable, Hashable {
    
    var id: UUID { get set }
    
    var imageName: String? { get set }
    var emoji: String? { get set }
    var title: String { get set }
    var description: String { get set }
    var prompt: String? { get set }
    var components: [PanelComponent] { get set }
    
}
