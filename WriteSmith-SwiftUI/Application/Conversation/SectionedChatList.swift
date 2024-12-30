//
//  SectionedChatList.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/3/24.
//

import CoreData
import Foundation
import SwiftUI

struct SectionedChatList: View {
    
    var emptyTitleText: Text
    var emptyDescriptionText: Text?
    var sectionedChats: SectionedFetchResults<String, Chat>
    
    
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
                
                if sectionedChats.count == 0 {
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
                
                ForEach(sectionedChats) { chatSection in
                    Section(content: {
                        ForEach(chatSection) { chat in
                            LazyVStack {
                                if chat.text != nil || chat.imageData != nil, let chatSender = chat.sender, let sender = Sender(rawValue: chatSender) {
                                    HStack {
                                        // Chat bubble view
                                        ChatBubbleContainer(
                                            chat: chat) // TODO: Is this fine here? I think I should make another class for just ChatBubbleView and have the one with conversationChatGenerator in ConversationChatBubbleView
                                        
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
                    }, header: {
                        Spacer()
                        
                        HStack {
                            Text(chatSection.id)
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                                .foregroundStyle(Colors.textOnBackgroundColor)
                            
                            Spacer()
                        }
                    })
                }
            }
            .background(Colors.background)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    withAnimation {
                        isDisplayingRemoveButtons.toggle()
                    }
                }) {
                    if isDisplayingRemoveButtons {
                        Text("Done")
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                    } else {
                        Text("Edit")
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                    }
                }
                .foregroundStyle(Colors.navigationItemColor)
            }
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
//    @SectionedFetchRequest<String, Chat>(
//        sectionIdentifier: \.daySectionIdentifier,
//        sortDescriptors: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)],
//        predicate: NSPredicate(format: "%K = %d", #keyPath(Chat.favorited), true),
//        animation: .default)
//    var sectionedChats
//    
//    return NavigationStack {
//        SectionedChatList(
//            emptyTitleText: Text("No Chats"),
//            emptyDescriptionText: Text("Go back and add a chat!"),
//            sectionedChats: sectionedChats)
//    }
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
//
