//
//  ConversationView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import CoreData
import FaceAnimation
import FirebaseAnalytics
import SwiftUI
import UIKit

struct ConversationView: View, KeyboardReadable {
    
    @ObservedObject var conversation: Conversation
    @FetchRequest var persistentAttachments: FetchedResults<PersistentAttachment>
    @Binding private var doGenerateBlankRemoveFirstChatIfInConversation: Bool
    @ObservedObject private var conversationChatGenerator: ConversationChatGenerator
    private var onCreateConversation: (Assistant?) -> Void
    private var onOpenCall: () -> Void
    private var onSpeakText: (String) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.requestReview) private var requestReview
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    //    @StateObject private var conversationChatGenerator: ConversationChatGenerator_Legacy = ConversationChatGenerator_Legacy()
    
//    private static let maxKeepInMindImageChats = 1
    
    private let chatsBottomPadding: CGFloat = 140.0
    
    private let faceFrameDiameter: CGFloat = 76.0
    
    private static let notFirstLaunchEver: Bool = UserDefaults.standard.bool(forKey: Constants.UserDefaults.notFirstLaunchEver)
    
    
    @FetchRequest<Chat> private var chats: FetchedResults<Chat>
    
    @StateObject private var conversationDrawerGenerator = ActionDrawerGenerator() // TODO: Move this to a container or something probably
    
    @State private var userChatBubbleImageSystemName: String = "pencil"
    
    @State private var isDisplayingLoadingChatBubble: Bool = false
    
    @State private var isShowingConversationSuggestions: Bool = false
    
    @State private var keepInMindImageChatToOverwrite: Chat?
    
    @State private var presentingAction: Action?
    
    @State private var isAtChatScrollViewBottom: Bool = false
    @State private var isSuggestionsViewActive: Bool = false
    
    @State private var alertShowingErrorOverwritingKeepInMindImageChat: Bool = false
    @State private var alertShowingUpgradeForUnlimitedChats: Bool = false
    
    @State private var isShowingAssistantInformationView: Bool = false
    @State private var isShowingAttachmentInformationView: Bool = false
    @State private var isShowingEssayActionView: Bool = false
    @State private var isShowingFlashCardCollectionCreator: Bool = false
    @State private var isShowingNewConversationView: Bool = false
    @State private var isShowingUltraView: Bool = false
    
    @State private var keyboardStatus: KeyboardStatus?
    
    @State private var currentlyDraggedChat: Chat?
    
    
    init(conversation: Conversation, persistentAttachments: FetchRequest<PersistentAttachment>, doGenerateBlankRemoveFirstChatIfInConversation: Binding<Bool>, conversationChatGenerator: ConversationChatGenerator, onCreateConversation: @escaping (Assistant?) -> Void, onOpenCall: @escaping () -> Void, onSpeakText: @escaping (String) -> Void) {
        self.conversation = conversation
        self._persistentAttachments = persistentAttachments
        self._doGenerateBlankRemoveFirstChatIfInConversation = doGenerateBlankRemoveFirstChatIfInConversation
        self.conversationChatGenerator = conversationChatGenerator
        self.onCreateConversation = onCreateConversation
        self.onOpenCall = onOpenCall
        self.onSpeakText = onSpeakText
        
        // Set chats FetchRequest
        self._chats = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: true)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.objectID),
            animation: .default)
        
//        // If no chats and persistentAttachment is nil because since an attachment is present the first chat was deleted then add first chat
//        DispatchQueue.main.async {
//            if conversation.chats?.count == 0 && (conversation.persistentAttachments == nil || conversation.persistentAttachments!.count == 0) {
//                let newChatText: String = conversation.assistant?.initialMessage ?? FirstChats.getRandomFirstChat()
//                do {
//                    // TODO: This uses CDClient mainManagedObjectContext instead of viewContext, is there a better way to do this?
//                    try withAnimation(.none) {
//                        try ChatCDHelper.appendChat(
//                            sender: .ai,
//                            text: newChatText,
//                            to: conversation,
//                            in: CDClient.mainManagedObjectContext)
//                    }
//                } catch {
//                    // TODO: Handle errors
//                    print("Error appending chat in ConversationView... \(error)")
//                }
//            } else {
//                print("HERE")
//            }
//        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                let _ = Self._printChanges()
                // Top Bar Section
                ConversationTopBarView(
                    conversation: conversation,
                    isShowingAssistantInformationView: $isShowingAssistantInformationView,
                    isShowingAttachmentInformationView: $isShowingAttachmentInformationView,
                    persistentAttachments: _persistentAttachments)
                
                // Action Collection Display
                if let actionCollection = conversation.actionCollection {
                    EssayActionCollectionFlowMiniView(
                        actionCollection: actionCollection,
                        selectedAction: $presentingAction)
//                    .padding([.leading, .trailing])
                    .padding()
                }
                
                // Flash Card Collection Display
                if let persistentAttachment = persistentAttachments.first,
                   let attachmentTypeString = persistentAttachment.attachmentType,
                   let attachmentType = AttachmentType(rawValue: attachmentTypeString),
                   attachmentType == .flashcards,
                   let flashCardCollection = persistentAttachment.flashCardCollection {
                    ConversationFlashCardCollectionMiniContainer(
                        attachmentTitle: persistentAttachment.generatedTitle ?? "",
                        flashCardCollection: flashCardCollection)
                        .padding(.bottom, 8)
                }
                
                ConversationChatsView(
                    conversation: conversation,
                    chats: chats,
                    presentingAction: $presentingAction,
                    conversationChatGenerator: conversationChatGenerator,
                    isAtChatScrollViewBottom: $isAtChatScrollViewBottom,
                    isDisplayingLoadingChatBubble: $isDisplayingLoadingChatBubble,
                    isShowingConversationSuggestions: $isShowingConversationSuggestions,
                    isShowingFlashCardCollectionCreator: $isShowingFlashCardCollectionCreator,
                    currentlyDraggedChat: $currentlyDraggedChat,
                    doGenerateBlankRemoveFirstChatIfInConversation: $doGenerateBlankRemoveFirstChatIfInConversation,
                    onSpeakText: onSpeakText)
                
                Spacer()
                
                ConversationEntryView(
                    conversation: conversation,
                    chats: chats,
                    doGenerateBlankRemoveFirstChatIfInConversation: $doGenerateBlankRemoveFirstChatIfInConversation,
                    isShowingConversationSuggestions: $isShowingConversationSuggestions,
                    isShowingUltraView: $isShowingUltraView,
                    isSuggestionsViewActive: $isSuggestionsViewActive,
                    conversationChatGenerator: conversationChatGenerator,
                    onOpenCall: onOpenCall)
                    .padding(.top, premiumUpdater.isPremium ? -50.0 /* This is the height of the linear gradient in entry */ : /* This is just some number that seems to work lol */ -120.0)
            }
//            .padding(.bottom, (keyboardStatus == .willShow || keyboardStatus == .isShowing) ? 8.0 : 48.0)
        }
        .background(Colors.background)
        .actionCollectionFlowPresenter(presentingAction: $presentingAction)
        .conversationFlashCardCollectionCreatorPopup(conversation: conversation, isPresented: $isShowingFlashCardCollectionCreator)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .padding(.top, -42)
        .conversationToolbar(
            conversation: conversation,
            isShowingAssistantInformationView: $isShowingAssistantInformationView,
            isShowingAttachmentInformationView: $isShowingAttachmentInformationView,
            onCreateConversation: { onCreateConversation(nil) })
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "\(Self.self)",
                                           AnalyticsParameterScreenClass: "\(Self.self)"])
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                requestReview()
            }
        }
//        .onChange(of: persistentAttachments.first, perform: onChangeAttachment)
        .onReceive(conversationChatGenerator.$isLoading) { newValue in
            // If false and isGenerating is false set isSuggestionsViewActive to true, otherwise set isSuggestionsViewActive to false
            if !newValue && !conversationChatGenerator.isGenerating {
                isSuggestionsViewActive = true
            } else {
                isSuggestionsViewActive = false
            }
        }
        .onReceive(conversationChatGenerator.$isGenerating) { newValue in
            // If false and isLoading is false set isSuggestionsViewActive to true, otherwise set isSuggestionsViewActive to false
            if !newValue && !conversationChatGenerator.isLoading {
                isSuggestionsViewActive = true
            } else {
                isSuggestionsViewActive = false
            }
        }
        .onReceive(conversationChatGenerator.$isLoading, perform: { isLoading in
            if isLoading {
                withAnimation {
                    isDisplayingLoadingChatBubble = isLoading
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                    isDisplayingLoadingChatBubble = false
                })
            }
        })
        .onReceive(keyboardPublisher) { keyboardStatus in
            if self.keyboardStatus != keyboardStatus {
                self.keyboardStatus = keyboardStatus
            }
        }
        .popover(isPresented: $isShowingAssistantInformationView, attachmentAnchor: .point(.top)) {
            AssistantInformationView(
                isPresented: $isShowingAssistantInformationView,
                conversation: conversation)
            .background(Colors.background)
        }
        .popover(isPresented: $isShowingAttachmentInformationView, attachmentAnchor: .point(.top)) {
            AttachmentInformationView(
                isPresented: $isShowingAttachmentInformationView,
                conversation: conversation,
                persistentAttachments: _persistentAttachments)
            .background(Colors.background)
        }
        .clearFullScreenCover(isPresented: $conversationChatGenerator.isShowingPromoImageGenerationView) {
            PromoGenerateImagesView(isShowing: $conversationChatGenerator.isShowingPromoImageGenerationView)
        }
        .clearFullScreenCover(isPresented: $isShowingNewConversationView) {
            ConversationCreationAssistantsView(
                isPresented: $isShowingNewConversationView,
                onCreateConversation: { assistant in
                    onCreateConversation(assistant)
                })
        }
        .ultraViewPopover(isPresented: $isShowingUltraView)
        //        .keyboardDismissingTextFieldToolbar("Done", color: Colors.buttonBackground)
        .scrollDismissesKeyboard(.immediately)
        .alert("Upgrade for FREE", isPresented: $alertShowingUpgradeForUnlimitedChats, actions: {
            Button("Cancel", role: nil, action: {
                
            })
            
            Button("Start Free Trial", role: .cancel, action: {
                isShowingUltraView = true
            })
        }) {
            Text("Please upgrade for unlimited chats. Tap Start Free Trial to get Unlimited + GPT-4o for FREE!")
        }
    }
    
}

//#Preview {
//    let assistantsFetchRequest = Assistant.fetchRequest()
//    assistantsFetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(Assistant.featured), true)
//    
//    var assistant: Assistant?
//    CDClient.mainManagedObjectContext.performAndWait {
//        assistant = try? CDClient.mainManagedObjectContext.fetch(assistantsFetchRequest)[safe: 0]
//    }
//    
//    let conversation = Conversation(context: CDClient.mainManagedObjectContext)
//    
//    conversation.assistant = assistant
//    
//    //    let chat1 = Chat(context: CDClient.mainManagedObjectContext)
//    //    chat1.text = "Test"
//    //    chat1.sender = "user"
//    //    chat1.conversation = conversation
//    //
//    //    let chat2 = Chat(context: CDClient.mainManagedObjectContext)
//    //    chat2.text = "Test AI"
//    //    chat2.sender = "ai"
//    //    chat2.conversation = conversation
//    //
//    //    let chat3 = Chat(context: CDClient.mainManagedObjectContext)
//    //    chat3.text = "Test"
//    //    chat3.sender = "user"
//    //    chat3.conversation = conversation
//    //
//    //    let chat4 = Chat(context: CDClient.mainManagedObjectContext)
//    //    chat4.text = "Test AI"
//    //    chat4.sender = "ai"
//    //    chat4.conversation = conversation
//    //
//    //    let chat5 = Chat(context: CDClient.mainManagedObjectContext)
//    //    chat5.imageData = UIImage(named: "AppIcon")!.jpegData(compressionQuality: 0.8)
//    //    chat5.sender = "user"
//    //    chat5.conversation = conversation
//    
//    CDClient.mainManagedObjectContext.performAndWait {
//        try? CDClient.mainManagedObjectContext.save()
//    }
//    
//    return NavigationStack {
//        
//        ZStack {
//            
//        }
//        .navigationDestination(isPresented: .constant(true)) {
//            ConversationView(
//                conversation: conversation,
//                persistentAttachments: FetchRequest(
//                    sortDescriptors: [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)],
//                    predicate: NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation)),
//                shouldDoInitialChatGeneration: .constant(false),
//                initialChatGenerationText: .constant(nil),
//                initialChatGenerationImage: .constant(nil),
//                initialChatGenerationImageURL: .constant(nil),
//                doGenerateBlankRemoveFirstChatIfInConversation: .constant(false),
//                conversationChatGenerator: ConversationChatGenerator(),
//                onCreateConversation: { assistant in
//                    
//                },
//                onOpenCall: {
//                    
//                },
//                onSpeakText: { text in
//                    
//                }
//            )
//            //        GADBannerViewRepresentable(bannerID: "ca-app-pub-3940256099942544/2934735716", isLoaded: .constant(true))
//            //            .frame(width: 320, height: 50)
//        }
//    }
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    .environmentObject(PremiumUpdater())
//    .environmentObject(ProductUpdater())
//    .environmentObject(RemainingUpdater())
//}
