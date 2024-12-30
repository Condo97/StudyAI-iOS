//
//  ConversationListView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/2/24.
//

import SwiftUI

struct ConversationListView: View {
    
    var conversations: FetchedResults<Conversation>
    var onCopyConversation: (Conversation) -> Void
    var onDeleteConversation: (Conversation) -> Void
    var onSelectConversation: (Conversation) -> Void
    
    var body: some View {
        ForEach(conversations) { conversation in
            if let latestChatText = conversation.latestChatText {
                ConversationRow(
                    conversation: conversation,
                    action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Call onSelectConversation
                        onSelectConversation(conversation)
                    })
                .padding([.leading, .trailing], 4)
                .contextMenu {
                    Button(action: {
                        // Call onCopyConversation
                        onCopyConversation(conversation)
                    }) {
                        Image(systemName: "doc.on.doc")
                        
                        Text("Copy")
                    }
                    
                    // TODO: Better share for Conversations
                    ShareLink(item: latestChatText) {
                        Image(systemName: "arrowshape.turn.up.right")
                        
                        Text("Share")
                    }
                    
                    Button(role: .destructive, action: {
                        // Call onDeleteConversation
                        onDeleteConversation(conversation)
                    }) {
                        Image(systemName: "trash")
                        
                        Text("Delete")
                    }
                }
            }
        }
//        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
}

#Preview {
    
//    @SectionedFetchRequest<String, Conversation>(
//        sectionIdentifier: \.dateSection,
//        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.latestChatDate, ascending: false)],
//        animation: .default)
//    var sectionedConversations
    @SectionedFetchRequest<Conversation>(
        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.latestChatDate, ascending: false)],
        animation: .default)
    var conversations
    
    return ConversationListView(
        conversations: conversations,
        onCopyConversation: { conversation in
            
        },
        onDeleteConversation: { conversation in
            
        },
        onSelectConversation: { conversation in
            
        })
    
}
