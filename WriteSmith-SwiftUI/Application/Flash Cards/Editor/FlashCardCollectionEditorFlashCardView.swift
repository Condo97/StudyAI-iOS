//
//  FlashCardCollectionEditorFlashCardView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct FlashCardCollectionEditorFlashCardView: View {
    
    @ObservedObject var flashCard: FlashCardCollectionEditorFlashCard
    
    var body: some View {
        VStack {
            FlashCardCollectionEditorTextField(
                subheading: "Term",
                placeholder: "",
                text: $flashCard.front)
            
            FlashCardCollectionEditorTextField(
                subheading: "Definition",
                placeholder: "",
                text: $flashCard.back)
        }
    }
    
}

//#Preview {
//    
//    FlashCardCollectionEditorFlashCardView(flashCard: FlashCardCollectionEditorFlashCard(front: "", back: ""))
//    
//}
