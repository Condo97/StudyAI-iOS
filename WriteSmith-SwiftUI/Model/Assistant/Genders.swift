//
//  Genders.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/3/24.
//

import Foundation

enum Pronouns {
    
    case heHim
    case sheHer
    case theyThem
    case custom
    
}

extension Pronouns {
    
    var name: String {
        switch self {
        case .heHim: "He/Him"
        case .sheHer: "She/Her"
        case .theyThem: "They/Them"
        case .custom: "Custom"
        }
    }
    
    static func from(name: String) -> Self {
        switch name.lowercased() {
        case Self.heHim.name.lowercased(): .heHim
        case Self.sheHer.name.lowercased(): .sheHer
        case Self.theyThem.name.lowercased(): .theyThem
        default: .custom
        }
    }
    
}
