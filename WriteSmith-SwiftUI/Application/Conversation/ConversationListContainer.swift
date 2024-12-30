//
//  ConversationListContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/2/24.
//

import SwiftUI

struct ConversationListContainer: View {
    
    @Binding var presentingConversation: Conversation?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @FetchRequest<Conversation>(
        sortDescriptors: [NSSortDescriptor(keyPath: \Conversation.latestChatDate, ascending: false)],
        animation: .default)
    private var conversations
    
    var body: some View {
        ConversationListView(
            conversations: conversations,
            onCopyConversation: { conversation in
                // TODO: Better copy for Conversations
                if let latestChatText = conversation.latestChatText {
                    PasteboardHelper.copy(latestChatText, showFooterIfNotPremium: true, isPremium: premiumUpdater.isPremium)
                }
            },
            onDeleteConversation: { conversation in
                // If conversation is presentingConversation set prresentingConversation to nil
                if conversation == presentingConversation {
                    presentingConversation = nil
                }
                
                // Delete Conversation and save context
                Task {
                    do {
                        try await viewContext.perform {
                            viewContext.delete(conversation)
                            
                            try viewContext.save()
                        }
                    } catch {
                        // TODO: Handle errors
                        print("Error saving viewContext after deleting conversatoins in MainView... \(error)")
                    }
                }
            },
            onSelectConversation: { conversation in
                // Set presentingConversation to conversation
                self.presentingConversation = conversation
            })
    }
    
}

//#Preview {
//    
//    ConversationListContainer(presentingConversation: .constant(try! CDClient.mainManagedObjectContext.fetch(Conversation.fetchRequest())[0]))
//    
//}
