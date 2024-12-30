//
//  ConversationChatsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/1/24.
//

import SwiftUI

struct ConversationChatsView: View, KeyboardReadable {
    
    var conversation: Conversation
    var chats: FetchedResults<Chat>
    @Binding var presentingAction: Action?
    @ObservedObject var conversationChatGenerator: ConversationChatGenerator
    @Binding var isAtChatScrollViewBottom: Bool
    @Binding var isDisplayingLoadingChatBubble: Bool
    @Binding var isShowingConversationSuggestions: Bool
    @Binding var isShowingFlashCardCollectionCreator: Bool
    @Binding var currentlyDraggedChat: Chat?
    @Binding var doGenerateBlankRemoveFirstChatIfInConversation: Bool
    var onSpeakText: (String) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @State private var initialChatScrollViewHeight: CGFloat = 0.0
    
    @State private var keyboardStatus: KeyboardStatus?
    
    @State private var shouldScrollOnKeyboardShow: Bool = false
    
    private let initialChatScrollViewHeightOffset: CGFloat = 350.0
    
    private var shouldShowInitialActions: Bool {
        // Should show initial actions if persistentAttachment is nil, actionCollection is nil, and there are no chats or just one AI chat
        (conversation.persistentAttachments == nil || conversation.persistentAttachments!.count == 0)
        &&
        conversation.actionCollection == nil
        &&
        (chats.count == 0 || (chats.count == 1 && chats[0].sender == Sender.ai.rawValue))
    }
    
    private var notFirstLaunchEver: Bool {
        UserDefaults.standard.bool(forKey: Constants.UserDefaults.notFirstLaunchEver)
    }
    
    var body: some View {
        // Chats
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: 8.0) {
                    // Initial Actions
                    if shouldShowInitialActions {
                        VStack(spacing: 0.0) {
                            ConversationInitialActionsView(
                                conversation: conversation,
                                notFirstLaunchEver: notFirstLaunchEver,
                                presentingAction: $presentingAction,
                                isShowingFlashCardCollectionCreator: $isShowingFlashCardCollectionCreator,
                                doGenerateBlankRemoveFirstChatIfInConversation: $doGenerateBlankRemoveFirstChatIfInConversation
                            )
                        }
                        .transition(.moveUp)
                    }
                    
                    // Chat
                    ForEach(chats) { chat in
                        if let chatSender = chat.sender, let sender = Sender(rawValue: chatSender) {
                            if (chat.text != nil && !chat.text!.isEmpty)
                                ||
                                chat.imageData != nil
                                ||
                                (chat.imageURL != nil && !chat.imageURL!.isEmpty) {
                                ConversationChatBubbleView(
                                    conversation: conversation,
                                    chat: chat,
                                    onSpeakText: onSpeakText)
                            }
                        }
                    }
                    
                    // TODO: If shouldShowInitialActions and there is exra space below the chat list show a couple suggestions like "What can you do?" "How can you help with homework?" etc
                    
                    if let streamingChat = conversationChatGenerator.streamingChat,
                       conversationChatGenerator.isGenerating {
                        ChatBubbleView(
                            text: streamingChat,
                            imageData: nil,
                            imageURL: nil,
                            sender: .ai,
                            isFavorited: false,
                            isKeptInMind: false,
                            assistant: conversation.assistant)
                        .padding([.leading, .trailing])
                        .onChange(of: streamingChat) { _ in
                            if isAtChatScrollViewBottom {
                                // Scroll to the bottom when a new message is added
                                proxy.scrollTo("bottom_spacer", anchor: .bottom)
                            }
                        }
                    }
                    
                    if isDisplayingLoadingChatBubble {
                        BubbleBackgroundView(
                            sender: .ai,
                            assistant: conversation.assistant,
                            content: {
                                HStack {
                                    PulsatingDotsView(count: 4, size: 16.0)
                                        .foregroundStyle(Colors.elementBackgroundColor)
                                    
                                    if conversationChatGenerator.isLoadingWebSearch,
                                       let webSearchQuery = conversationChatGenerator.webSearchQuery {
                                        Text("Searching \(webSearchQuery)...")
                                            .font(.custom(Constants.FontName.black, size: 14.0))
                                            .foregroundStyle(Colors.aiChatTextColor)
                                            .padding(8)
                                    } else if conversationChatGenerator.isLoadingFlashCards {
                                        Text("Creating Flash Cards...")
                                            .font(.custom(Constants.FontName.black, size: 14.0))
                                            .foregroundStyle(Colors.aiChatTextColor)
                                            .padding(8)
                                    }
                                }
                                .padding(.leading, 5)
                                .padding(.trailing, 9)
                            })
                        .padding([.leading, .trailing])
                        .transition(.moveUp)
                    }
                    
                    // Bottom spacer
                    Spacer(minLength: premiumUpdater.isPremium ? 48.0 : 120.0)
                        .id("bottom_spacer")
                }
                .onChange(of: keyboardStatus) { newValue in
                    if newValue == .willShow {
                        shouldScrollOnKeyboardShow = isAtChatScrollViewBottom
                    }
                    if newValue == .isShowing && shouldScrollOnKeyboardShow {
                        // Scroll to bottom when keyboard is showing
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            proxy.scrollTo("bottom_spacer", anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isShowingConversationSuggestions) { newValue in
                    if newValue, isAtChatScrollViewBottom {
                        // Scroll to the bottom when suggestions view is showing
                        proxy.scrollTo("bottom_spacer", anchor: .bottom)
                    }
                }
                .onChange(of: chats.count) { newValue in
                    if isAtChatScrollViewBottom {
                        // Scroll to the bottom when a new message is added
                        proxy.scrollTo("bottom_spacer", anchor: .bottom)
                    }
                }
                //                .onChange(of: conversationChatGenerator.isGenerating) { _ in
                //                    if isAtChatScrollViewBottom {
                //                        // Scroll to the bottom when a new message is added
                //                            proxy.scrollTo("bottom_spacer", anchor: .bottom)
                //                    }
                //                }
                .onChange(of: isDisplayingLoadingChatBubble) { newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            if isAtChatScrollViewBottom {
                                // Scroll to the bottom when a new message is added
                                proxy.scrollTo("bottom_spacer", anchor: .bottom)
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if isAtChatScrollViewBottom {
                                // Scroll to the bottom when a new message is added
                                proxy.scrollTo("bottom_spacer", anchor: .bottom)
                            }
                        }
                    }
                }
                .onReceive(conversationChatGenerator.$isGenerating) { newValue in
                    DispatchQueue.main.async {
                        if !newValue && self.isAtChatScrollViewBottom {
                            proxy.scrollTo("bottom_spacer", anchor: .bottom)
                        }
                    }
                }
                .onReceive(keyboardPublisher) { keyboardStatus in
                    if self.keyboardStatus != keyboardStatus {
                        self.keyboardStatus = keyboardStatus
                    }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.frame(in: .global).maxY) { _ in
                            // Check if the user is at the bottom
                            isAtChatScrollViewBottom = geometry.frame(in: .global).maxY <= initialChatScrollViewHeight
                        }
                    }
                )
                .onAppear {
                    proxy.scrollTo("bottom_spacer", anchor: .bottom)
                }
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        if abs(gesture.translation.height) >= 20 {
                            withAnimation {
                                currentlyDraggedChat = nil
                            }
                        }
                    })
            .scrollIndicators(.never)
        }
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    // Check if the user is at the bottom
                    initialChatScrollViewHeight = geometry.size.height + initialChatScrollViewHeightOffset
                }
            }
        )
    }
    
}

//#Preview {
//    
//    ConversationChatsView()
//    
//}
