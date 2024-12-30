//  ConversationView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.

import CoreData
import FaceAnimation
import FirebaseAnalytics
import SwiftUI
import UIKit

struct ConversationView: View, KeyboardReadable {
    @Binding private var conversation: Conversation
    @State private var shouldShowFirstConversationChats: Bool
    @Binding private var shouldDoInitialChatGeneration: Bool
    @Binding private var initialChatGenerationText: String?
    @Binding private var initialChatGenerationImage: UIImage?
    @Binding private var initialChatGenerationImageURL: String?
    @ObservedObject private var conversationChatGenerator: ConversationChatGenerator
    @Environment(
        .colorScheme) private var colorScheme
    @Environment(
        .requestReview) private var requestReview
    @Environment(
        .managedObjectContext) private var viewContext
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
   
    private let chatsBottomPadding: CGFloat = 140.0
    private let faceFrameDiameter: CGFloat = 76.0
    private static let notFirstLaunchEver: Bool = UserDefaults.standard.bool(forKey: Constants.UserDefaults.notFirstLaunchEver)
    @FetchRequest<Chat> private var chats: FetchedResults<Chat>
    @StateObject private var conversationDrawerGenerator = ActionDrawerGenerator() 
    @State private var userChatBubbleImageSystemName: String = "pencil"
    @State private var isDisplayingLoadingChatBubble: Bool = false
    @State private var keepInMindImageChatToOverwrite: Chat?
    @State private var presentingAction: Action?
    @State private var isAtChatScrollViewBottom: Bool = false
    @State private var isSuggestionsViewActive: Bool = false
    @State private var initialChatScrollViewHeight: CGFloat = 0.0
    @State private var initialChatScrollViewHeightOffset: CGFloat = 250.0
    @State private var alertShowingErrorOverwritingKeepInMindImageChat: Bool = false
    @State private var alertShowingUpgradeForUnlimitedChats: Bool = false
    @State private var isShowingAssistantInformationView: Bool = false
    @State private var isShowingAttachmentInformationView: Bool = false
    @State private var isShowingEssayActionView: Bool = false
    @State private var isShowingInterstitial: Bool = false
    @State private var isShowingNewConversationView: Bool = false
    @State private var isShowingUltraView: Bool = false
    @State private var keyboardStatus: KeyboardStatus?
    @State private var currentlyDraggedChat: Chat?

    private var shouldShowInitialActions: Bool {
        // Should show initial actions if persistentAttachment is nil, actionCollection is nil, and there are no chats or just one AI chat
        conversation.persistentAttachment == nil
        &&
        conversation.actionCollection == nil
        &&
        (chats.count == 0 || (chats.count == 1 && chats[0].sender == Sender.ai.rawValue))
    }

    init(conversation: Binding<Conversation>, shouldShowFirstConversationChats: Bool, shouldDoInitialChatGeneration: Binding<Bool>, initialChatGenerationText: Binding<String?>, initialChatGenerationImage: Binding<UIImage?>, initialChatGenerationImageURL: Binding<String?>, conversationChatGenerator: ConversationChatGenerator) {
        self._conversation = conversation
        self._shouldShowFirstConversationChats = State(initialValue: shouldShowFirstConversationChats)
        self._shouldDoInitialChatGeneration = shouldDoInitialChatGeneration
        self._initialChatGenerationText = initialChatGenerationText
        self._initialChatGenerationImage = initialChatGenerationImage
        self._initialChatGenerationImageURL = initialChatGenerationImageURL
        self.conversationChatGenerator = conversationChatGenerator

        // Set chats FetchRequest
        self._chats = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: true)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.wrappedValue.objectID),
            animation: .default)

        // If no chats and persistentAttachment is nil because since an attachment is present the first chat was deleted then add first chat
        DispatchQueue.main.async {
            if conversation.wrappedValue.chats?.count == 0 && conversation.wrappedValue.persistentAttachment == nil {
                let newChatText: String = conversation.wrappedValue.assistant?.initialMessage ?? FirstChats.getRandomFirstChat()
                do {
                    // TODO: This uses CDClient mainManagedObjectContext instead of viewContext, is there a better way to do this?
                    try withAnimation(.none) {
                        try ChatCDHelper.appendChat(
                            sender: .ai,
                            text: newChatText,
                            to: conversation.wrappedValue,
                            in: CDClient.mainManagedObjectContext)
                    }
                } catch {
                    // TODO: Handle errors
                    print("Error appending chat in ConversationView... \(error)")
                }
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                // Top Bar Section
                ConversationHeader(conversation: $conversation)
                
                // Action Collection Display
                if conversation.actionCollection != nil {
                    actionCollectionDisplay
                }
                
                if shouldShowInitialActions {
                    // Banner Ad
                    if !premiumUpdater.isPremium && ConversationView.notFirstLaunchEver {
                        BannerView(bannerID: Keys.Ads.Banner.chatView)
                            .padding(.bottom, 8)
                    }
                    
                    ScrollView(.vertical) {
                        // Attachments
                        HStack {
                            Text("Add Content")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                                .foregroundStyle(Colors.textOnBackgroundColor)
                            
                            Spacer()
                        }
                        .padding([.leading, .trailing])
                        
                        HStack {
                            Text("Engage with lectures, assignments, quiz prep and more.")
                                .font(.custom(Constants.FontName.light, size: 12.0))
                                .foregroundStyle(Colors.textOnBackgroundColor)
                            
                            Spacer()
                        }
                        .padding([.leading, .trailing])
                        
                        attachments
                            .padding([.leading, .trailing])
                        
                        ActionCollectionFlowCreatorView(conversation: conversation, presentingAction: $presentingAction)
                            .padding([.leading, .trailing])
                    }
                } else {
                    // Chats
                    ChatDisplay(conversation: $conversation, conversationChatGenerator: conversationChatGenerator)
                }
                
                Spacer()
                
                ConversationEntry(text: $text) { text in
                    // Handle text submission
                }   
                .padding(.top, premiumUpdater.isPremium ? -50.0 : -120.0)
            }
            .padding(.bottom, (keyboardStatus == .willShow || keyboardStatus == .isShowing) ? 8.0 : 48.0)
            .actionCollectionFlowPresenter(presentingAction: $presentingAction)
        }
        .background(Colors.background)
        .background(
            InterstitialView(interstitialID: Keys.Ads.Interstitial.chatView, disabled: $premiumUpdater.isPremium, isPresented: $isShowingInterstitial))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .padding(.top, -42)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AssistantActionButtons()
            }
        }
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "\(Self.self)", AnalyticsParameterScreenClass: "\(Self.self)"])
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                requestReview()
            }
        }
        .onChange(of: conversation.persistentAttachment) { newValue in
            // Unwrap persistentAttachment, otherwise return
            guard let newValue = newValue else {
                // TODO: Handle Errors if Necessary
                print("Error unwrapping persistentAttachment in ConversationView!")
                return
            }
        }
    }

} 
