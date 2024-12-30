//
//  ConversationFlashCardCollectionCreatorPopup.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct ConversationFlashCardCollectionCreatorPopup: ViewModifier {
    
    var conversation: Conversation
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                ConversationFlashCardCollectionCreatorView(
                    isPresented: $isPresented,
                    conversation: conversation)
            }
    }
    
}


extension View {
    
    func conversationFlashCardCollectionCreatorPopup(conversation: Conversation, isPresented: Binding<Bool>) -> some View {
        self
            .modifier(ConversationFlashCardCollectionCreatorPopup(
                conversation: conversation,
                isPresented: isPresented))
    }
    
}


//#Preview {
//    
//    ConversationFlashCardCollectionCreatorPopup()
//    
//}
