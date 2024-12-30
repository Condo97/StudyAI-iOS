//
//  ChatBubbleContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/2/24.
//

import SwiftUI

struct ChatBubbleContainer: View {
    
    @ObservedObject var chat: Chat
    var assistant: Assistant?
    var onApplyFlashCardCollection: (() -> Void)?
    var onReadAloud: (() -> Void)?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var keepInMindImageChatToOverwrite: Chat?
    
    @State private var alertShowingErrorOverwritingKeepInMindImageChat: Bool = false
    
    private static let maxKeepInMindImageChats = 1 // TODO: Move to a better location
    
    var alertShowingMaxKeepInMind: Binding<Bool> {
        Binding(
            get: {
                // Alert is showing if keepInMindChatToOverwrite is not nil
                keepInMindImageChatToOverwrite != nil
            },
            set: { value in
                // Set keepInMindChatToOverwrite to nil if this is set to false
                if !value {
                    keepInMindImageChatToOverwrite = nil
                }
            })
    }
    
    var chatSender: Sender {
        chat.sender == nil ? .ai : Sender(rawValue: chat.sender!) ?? .ai
    }
    
    var body: some View {
        
        ChatBubbleView(
            text: chat.text,
            imageData: chat.imageData,
            imageURL: chat.imageURL,
            flashCardCollection: chat.flashCardCollection,
            sender: chatSender,
            isFavorited: chat.favorited,
            isKeptInMind: chat.keepInMind,
            assistant: assistant,
            onApplyFlashCardCollection: onApplyFlashCardCollection,
            onDelete: deleteChat,
            onFavorite: toggleFavorite,
            onKeepInMind: toggleKeepInMind,
            onReadAloud: onReadAloud)
        .alert("Max Images in Mind", isPresented: alertShowingMaxKeepInMind, actions: {
            Button("Close", role: .cancel) {
                
            }
            
            Button("Overwrite", role: .destructive) { // TODO: Overwriting probably shouldn't be in this class, but how else would I add the contextMenu button
                // Unwrap conversation, otherwise return
                guard let conversation = chat.conversation else {
                    // TODO: Handle Errors
                    print("Error unwrapping conversation in ChatBubbleView!")
                    alertShowingErrorOverwritingKeepInMindImageChat = true
                    return
                }
                
                // Remove oldest keep in mind image
                do {
                    try ConversationCDHelper.removeKeepInMindOldestChatWithImageData(
                        for: conversation,
                        in: viewContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error deleting oldest keep in mind chat with image data in ConversationView... \(error)")
                    alertShowingErrorOverwritingKeepInMindImageChat = true
                    return // Returning because I don't think it's a good idea to save two I guess.. Maybe I should show another error?
                }
                
                // Set chat to keepInMind and save
                keepInMindImageChatToOverwrite?.keepInMind = true
                
                do {
                    try viewContext.performAndWait {
                        try viewContext.save()
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error saving viewContext in ConversationView... \(error)")
                    alertShowingErrorOverwritingKeepInMindImageChat = true
                }
                
                // Set keepInMindImageChatToOverwrite to nil
                keepInMindImageChatToOverwrite = nil
            }
        }) {
            Text("AI can keep \(ChatBubbleContainer.maxKeepInMindImageChats) image\(ChatBubbleContainer.maxKeepInMindImageChats == 1 ? "" : "s") in mind at one time. Overwrite to keep new image in mind?")
        }
        .alert("Error Saving to Keep in Mind", isPresented: $alertShowingErrorOverwritingKeepInMindImageChat, actions: {
            Button("Close", role: .cancel) {
                
            }
        }) {
            Text("There was an error overwriting your keep in mind image. Please report this and try again later.")
        }
        
    }
    
    func deleteChat() {
        // Delete chat from network
        let chatID = chat.chatID
        Task {
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle errors
                print("Error ensuring authToken in ChatView... \(error)")
                return
            }
            
            do {
                try await ChatHTTPSConnector.deleteChat(
                    authToken: authToken,
                    chatID: Int(chatID))
            } catch {
                // TODO: Handle errors
                print("Error deleting chat in ChatView... \(error)")
                return
            }
        }
        
        // Delete chat from CoreData
        viewContext.delete(chat)
        
        // Save context
        do {
            try viewContext.performAndWait {
                try viewContext.save()
            }
        } catch {
            // TODO: Handle errors
            print("Error saving context when deleting chat in ChatView... \(error)")
        }
    }
    
    func toggleKeepInMind() {
        // Ensure if chat intends to set keep in mind to true and chat has an image there is no other image kept in mind, otherwise show error and return
        if chat.keepInMind {
            if (chat.imageData != nil) || (chat.imageURL != nil && chat.imageURL!.isEmpty) {
                do {
                    guard let conversation = chat.conversation else {
                        // TODO: Handle Errors
                        print("Error unwrapping conversation in ChatBubbleView!")
                        return
                    }
                    
                    guard try !ConversationCDHelper.hasMaxKeepInMindImageData(
                        maxCount: ChatBubbleContainer.maxKeepInMindImageChats,
                        for: conversation,
                        in: viewContext) else {
                        keepInMindImageChatToOverwrite = chat
                        return
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error getting if there are a max number of kept in mind chats in ConversationView... \(error)")
                }
            }
        }
        
        // Set keepInMind and save
        chat.keepInMind.toggle()
        
        do {
            try viewContext.performAndWait {
                try viewContext.save()
            }
        } catch {
            // TODO: Handle Errors
            print("Error saving viewContext in ConversationView... \(error)")
        }
    }
    
    func toggleFavorite() {
        // Toggle favorited and save
        chat.favorited.toggle()
        
        do {
            try viewContext.performAndWait {
                try viewContext.save()
            }
        } catch {
            // TODO: Handle Errors
            print("Error saving viewContext in ConversationView... \(error)")
        }
    }
}

//#Preview {
//    
//    let fetchRequest = Chat.fetchRequest()
//    let chat = try! CDClient.mainManagedObjectContext.performAndWait {
//        return try CDClient.mainManagedObjectContext.fetch(fetchRequest)[0]
//    }
//    
//    return ChatBubbleContainer(
//        chat: chat,
//        assistant: chat.conversation!.assistant,
//        onApplyFlashCardCollection: {
//            
//        },
//        onReadAloud: {
//            
//        }
//    )
//    
//}
