//
//  ConversationToolbar.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/1/24.
//

import SwiftUI

struct ConversationToolbar: ViewModifier {
    
    var conversation: Conversation
    @Binding var isShowingAssistantInformationView: Bool
    @Binding var isShowingAttachmentInformationView: Bool
    var onCreateConversation: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        // Helps the assistant information button be pressed
                        Button(action: {
                            Task {
                                // Get most recent persistent attachment
                                let fetchRequest = PersistentAttachment.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation)
                                fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)]
                                fetchRequest.fetchLimit = 1
                                
                                let persistentAttachment: PersistentAttachment?
                                do {
                                    persistentAttachment = try await viewContext.perform {
                                        try viewContext.fetch(fetchRequest)[safe: 0]
                                    }
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error fetching persistent attachments in ConversationToolbar... \(error)")
                                    persistentAttachment = nil
                                }
                                
                                // This condition is to keep it in line with the change of the top button depending on if the chat has an attachment
                                if let persistentAttachment = persistentAttachment,
                                   let attachmentTypeString = persistentAttachment.attachmentType,
                                   let attachmentType = AttachmentType(rawValue: attachmentTypeString) {
                                    self.isShowingAttachmentInformationView = true
                                } else {
                                    self.isShowingAssistantInformationView = true
                                }
                            }
                        }) {
                            Color.clear
                                .frame(width: 228)
                        }
                    }
                }
                
                if !premiumUpdater.isPremium {
                    UltraToolbarItem()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onCreateConversation) {
                        if premiumUpdater.isPremium {
                            Text(Image(systemName: "plus.bubble"))
                                .font(.custom(Constants.FontName.medium, size: 19.0))
                        } else {
                            Text(Image(systemName: "plus.bubble"))
                                .font(.custom(Constants.FontName.medium, size: 19.0))
                        }
                    }
                    .foregroundStyle(Colors.navigationItemColor)
                    .padding(.vertical, 4)
                    .padding(.horizontal, -4)
                }
            }
    }
    
}

extension View {
    
    func conversationToolbar(conversation: Conversation, isShowingAssistantInformationView: Binding<Bool>, isShowingAttachmentInformationView: Binding<Bool>, onCreateConversation: @escaping () -> Void) -> some View {
        self
            .modifier(ConversationToolbar(
                conversation: conversation,
                isShowingAssistantInformationView: isShowingAssistantInformationView,
                isShowingAttachmentInformationView: isShowingAttachmentInformationView,
                onCreateConversation: onCreateConversation))
    }
    
}

//#Preview {
//    
//    ConversationToolbar()
//    
//}
