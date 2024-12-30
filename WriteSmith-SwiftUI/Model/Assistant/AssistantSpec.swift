//
//  AssistantSpec.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/28/24.
//

import Foundation
import UIKit

struct AssistantSpec {
    var name: String
    var category: AssistantCategories
    var shortDescription: String?
    var description: String?
    
    var systemPrompt: String?
    var initialMessage: String?
    var premium: Bool
    
    var emoji: String?
    var imageName: String?
    var faceStyle: FaceStyles?
    
    var pronouns: Pronouns?
    
    var usageMessages: Int64
    var usageUsers: Int64
}
