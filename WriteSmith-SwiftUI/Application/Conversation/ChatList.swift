//
//  ChatList.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/3/24.
//

import CoreData
import Foundation
import SwiftUI

struct ChatList: View {
    
    var emptyTitleText: Text
    var emptyDescriptionText: Text?
    var chats: FetchedResults<Chat>
    var onApplyFlashCardCollection: ((FlashCardCollection) -> Void)?
    var onSpeakText: ((String) -> Void)?
    
//    @FetchRequest var chats: FetchedResults<Chat>
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isShowingFullScreenImageView: Bool = false
    
    @State private var isDisplayingRemoveButtons: Bool = false
    
    @State private var currentlyDraggedChat: Chat?
    
    @State private var fullScreenImageViewImage: Image?
    
    
//    init(emptyTitleText: Text, emptyDescriptionText: Text, assistant: Binding<Assistant?>, chats: FetchRequest<Chat>, conversationChatGenerator: Conversa) {
//        self._emptyTitleText = State(initialValue: emptyTitleText)
//        self._emptyDescriptionText = State(initialValue: emptyDescriptionText)
//        self._assistant = assistant
//        self._chats = chats
//    }
    
    var body: some View {
        VStack {
            ScrollView {
                Spacer()
                
                if chats.count == 0 {
                    HStack {
                        Spacer()
                        
                        VStack {
                            emptyTitleText
                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                            emptyDescriptionText
                                .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .foregroundStyle(Colors.text)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                
                ForEach(chats) { chat in
                    LazyVStack {
                        if chat.text != nil || chat.imageData != nil, let chatSender = chat.sender, let sender = Sender(rawValue: chatSender) {
                            HStack {
                                // Chat bubble view
                                ChatBubbleContainer(
                                    chat: chat,
                                    onApplyFlashCardCollection: onApplyFlashCardCollection == nil ? nil : {
                                        guard let flashCardCollection = chat.flashCardCollection else {
                                            print("Could not unwrap flashCardCollection in ChatBubbleContainer!")
                                            return
                                        }
                                        
                                        onApplyFlashCardCollection!(flashCardCollection)
                                    },
                                    onReadAloud: {
                                        guard let text = chat.text else {
                                            // TODO: Handle Errors
                                            print("Could not unwrap chat text in ChatList!)")
                                            return
                                        }
                                        
                                        onSpeakText?(text)
                                    }) // TODO: Is this fine here? I think I should make another class for just ChatBubbleView and have the one with conversationChatGenerator in ConversationChatBubbleView
                                
                                // Show remove buttons
                                if isDisplayingRemoveButtons {
                                    RemoveButton(remove: {
                                        deleteChat(chat, in: viewContext)
                                    })
                                    .padding(.leading)
                                }
                            }
                        }
                        
                        // Show divider if displaying remove buttons
                        if isDisplayingRemoveButtons {
                            Divider()
                        }
                    }
                }
            }
            .background(Colors.background)
        }
        .fullScreenCover(isPresented: $isShowingFullScreenImageView) {
            FullScreenImageView(
                isPresented: $isShowingFullScreenImageView,
                image: $fullScreenImageViewImage)
        }
    }
    
    
    func deleteChat(_ chat: Chat, in managedContext: NSManagedObjectContext) {
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
        managedContext.delete(chat)
        
        // Save context
        do {
            try managedContext.performAndWait {
                try managedContext.save()
            }
        } catch {
            // TODO: Handle errors
            print("Error saving context when deleting chat in ChatView... \(error)")
        }
    }
    
}

//#Preview {
//    
//    let conversationFetchRequest = Conversation.fetchRequest()
//    conversationFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Conversation.latestChatDate), ascending: true)]
//    
//    var conversation: Conversation?
//    try? CDClient.mainManagedObjectContext.performAndWait {
//        conversation = try CDClient.mainManagedObjectContext.fetch(conversationFetchRequest)[safe: 0]
//    }
//    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: true)],
//        predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation!.objectID),
//        animation: .default)
//    var chats: FetchedResults<Chat>
//    
//    return NavigationStack {
//        ChatList(
//            emptyTitleText: Text("No Chats"),
//            emptyDescriptionText: Text("Go back and add a chat!"),
//            chats: chats,
//            onApplyFlashCardCollection: { flashCardCollection in
//                
//            },
//            onSpeakText: { text in
//                
//            })
//    }
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
