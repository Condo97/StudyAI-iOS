//
//  ConversationChatBubbleView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/19/24.
//

import SwiftUI

struct ConversationChatBubbleView: View {
    
    var conversation: Conversation
    var chat: Chat
    var onSpeakText: ((String) -> Void)?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isLoadingApplyFlashCardCollection: Bool = false
    
    var shouldShowApplyFlashCardCollection: Bool {
        // Ensure not isLoadingApplyFlashCardCollection, otherwise return false
        guard !isLoadingApplyFlashCardCollection else {
            return false
        }
        
        // If chat contains chatFlashCardCollection check if persistentAttachment does not exist or if it does does not contain a flash card collection equal to the flash card collection and return true, otherwise return false
        if let chatFlashCardCollection = chat.flashCardCollection {
            // Get most recent persistent attachment TODO: Abstract this put this somewhere
            let fetchRequest = PersistentAttachment.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)]
            fetchRequest.fetchLimit = 1
            
            let persistentAttachment: PersistentAttachment
            do {
                let persistentAttachmentOptional = try viewContext.performAndWait {
                    try viewContext.fetch(fetchRequest)[safe: 0]
                }
                
                guard persistentAttachmentOptional != nil else {
                    // No persistent attachment, return true
                    return true
                }
                
                persistentAttachment = persistentAttachmentOptional!
            } catch {
                // Error getting persistent attachment, return true TODO: Handle Errors if Necessary
                print("Error getting chat persistent attachment in ConversationChatsView... \(error)")
                return true
            }
            
            // Return true if chatFlashCardCollection is not equal to persistentAttachment flashCardCollection
            return chatFlashCardCollection != persistentAttachment.flashCardCollection
        }
        
        return false
    }
    
    var body: some View {
        HStack {
            ChatBubbleContainer(
                chat: chat,
                assistant: conversation.assistant,
                onApplyFlashCardCollection: shouldShowApplyFlashCardCollection ? {
                    // Create PersistentAttachment with FlashCardCollection to Conversation
                    Task {
                        // Defer setting isLoadingApplyFlashCardCollection to false
                        defer {
                            DispatchQueue.main.async {
                                self.isLoadingApplyFlashCardCollection = false
                            }
                        }
                        
                        // Set isLoadingApplyFlashCardCollection to true
                        await MainActor.run {
                            isLoadingApplyFlashCardCollection = true
                        }
                        
                        guard let flashCardCollection = chat.flashCardCollection else {
                            // TODO: Handle Errors
                            print("Could not unwrap chat flash card collection in ConversationChatsView!")
                            return
                        }
                        
                        let persistentAttachment: PersistentAttachment
                        do {
                            persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createFlashCardsAttachmentUpdateCachedTextAndGeneratedTitle(
                                flashCardCollection: flashCardCollection,
                                title: nil,
                                in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error creating flash cards PersistentAttachment in ConversationChatsView... \(error)")
                            return
                        }
                        
                        do {
                            try await PersistentAttachmentCDHelper.update(persistentAttachment, conversation: conversation, in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error updating PersistentAttachment to Conversation in ConversationChatsView... \(error)")
                            return
                        }
                    }
                } : nil,
                onReadAloud: {
                    // Unwrap chat text
                    guard let chatText = chat.text else {
                        // TODO: Handle Errors
                        print("Could not unwrap chatText in ConversationChatBubbleView!")
                        return
                    }
                    
                    onSpeakText?(chatText)
                })
            .padding([.leading, .trailing])
            //                                    .transition(sender == .ai ? .opacity : .moveUp)
            .opacity(isLoadingApplyFlashCardCollection ? 0.6 : 1.0)
            .overlay {
                if isLoadingApplyFlashCardCollection {
                    ProgressView()
                }
            }
        }
    }
    
}

//#Preview {
//    
//    let conversation = try! CDClient.mainManagedObjectContext.fetch(Conversation.fetchRequest())[0]
//    
//    let chat = conversation.chats?.allObjects[0] as! Chat
//    
//    return ConversationChatBubbleView(
//        conversation: conversation,
//        chat: chat,
//        onSpeakText: { text in
//            
//        }
//    )
//    
//}
