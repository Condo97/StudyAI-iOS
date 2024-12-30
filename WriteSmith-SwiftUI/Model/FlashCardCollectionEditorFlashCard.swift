//
//  ManualFlashCardCollectionCreatorFlashCard.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import Foundation

class FlashCardCollectionEditorFlashCard: ObservableObject, Identifiable {
    
    var front: String
    var back: String
    
    init() {
        self.front = ""
        self.back = ""
    }
    
    init(front: String, back: String) {
        self.front = front
        self.back = back
    }
    
}
