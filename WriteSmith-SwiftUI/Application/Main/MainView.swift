//
//  MainView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import FaceAnimation
import FirebaseAnalytics
import SwiftUI

struct MainView: View {
    
    @Binding var faceAssistant: Assistant?
    @Binding var panelGroups: [PanelGroup]?
    @Binding var presentingConversation: Conversation?
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    private static let faceDiameter: CGFloat = 106.0
    private static let faceFrame: CGRect = CGRect(x: 0, y: 0, width: faceDiameter, height: faceDiameter)
    private static let facialFeaturesScaleFactor: CGFloat = 0.76
    private static let faceStartAnimation: FaceAnimation = FaceAnimationRepository.center(duration: 0.0)
    private let circleInnerPadding: CGFloat = 0.0
    
//    @StateObject private var conversationChatGenerator: ConversationChatGenerator_Legacy = ConversationChatGenerator_Legacy()
    
//    @State private var faceAssistant: Assistant?
    
    @State private var currentlyDraggedConversation: Conversation?
    
    @State private var selectedSuggestion: Suggestion?
    
    @State private var transitionToNewConversation: Bool = false
    
    @State private var isShowingAssistantsView: Bool = false
    @State private var isShowingCameraView: Bool = false
    @State private var isShowingExploreView: Bool = false
    @State private var isShowingFavoritesView: Bool = false
//    @State private var isShowingFaceAssistantSelectorView: Bool = false
    @State private var isShowingSettingsView: Bool = false
    
    @State private var initialChatGenerationText: String?
    @State private var initialChatGenerationImage: UIImage?
    @State private var initialChatGenerationImageURL: String?
    
    
    @State private var presentingPanel: Panel?
    private var isShowingPresentingPanelView: Binding<Bool> {
        Binding(
            get: {
                presentingPanel != nil
            },
            set: { newValue in
                if !newValue {
                    presentingPanel = nil
                }
            })
    }
    
    @State private var selectedAssistantSortItem: AssistantCategories?
    var isPresentingAssistantSortItem: Binding<Bool> {
        Binding(
            get: {
                selectedAssistantSortItem != nil
            },
            set: { value in
                if !value {
                    selectedAssistantSortItem = nil
                }
            })
    }
    
//    @State private var presentingConversation: Conversation?
    var isShowingPresentingConversation: Binding<Bool> {
        Binding(
            get: {
                presentingConversation != nil
            },
            set: { newValue in
                if !newValue {
                    presentingConversation = nil
                }
            })
    }
    
//    init(panelGroups: [PanelGroup]?) {
//        self._panelGroups = State(initialValue: panelGroups)
//        
//        // Set presentingConversation from ConversationResumingManager
//        #if false //DEBUG
//        
//        #else
//        // Set faceAssistant
//        do {
//            self._faceAssistant = State(initialValue: try CurrentAssistantPersistence.getAssistant(in: CDClient.mainManagedObjectContext))
//        } catch {
//            // TODO: Handle Errors
//            print("Error getting assistant from CurrentAssistantPersistence in MainView... \(error)")
//        }
//        
//        
//        #endif
//    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
//                        var _ = Self._printChanges()
                        // Banner Ad
                        if !premiumUpdater.isPremium {
                            BannerView(bannerID: Keys.Ads.Banner.conversationView)
                                .padding(.bottom)
                        }
                        
                        // Active Assistant
                        Button(action: {
                            // Create new Conversation with faceAssistant and set as presentingConversation
                            do {
                                let conversation = try ConversationCDHelper.appendConversation(
                                    modelID: premiumUpdater.isPremium ? GPTModels.gpt4o.rawValue : GPTModels.gpt4oMini.rawValue,
                                    assistant: faceAssistant,
                                    in: viewContext)
                                
                                self.presentingConversation = conversation
                            } catch {
                                // TODO: Handle Errors
                                print("Error appending Conversation in MainView... \(error)")
                            }
                        }) {
                            ZStack {
                                HStack {
                                    FaceAnimationResizableView(
//                                        frame: MainView.faceFrame,
                                        eyesImageName: FaceStyles.worm.eyesImageName,
                                        mouthImageName: FaceStyles.worm.mouthImageName,
                                        noseImageName: FaceStyles.worm.noseImageName,
                                        faceImageName: FaceStyles.worm.backgroundImageName,
                                        facialFeaturesScaleFactor: MainView.facialFeaturesScaleFactor,
                                        eyesPositionFactor: FaceStyles.worm.eyesPositionFactor,
                                        faceRenderingMode: FaceStyles.worm.faceRenderingMode,
                                        color: UIColor(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor),
                                        startAnimation: FaceAnimationRepository.center(duration: 0.0))
                                    .frame(width: MainView.faceDiameter, height: MainView.faceDiameter)
                                    .padding(.leading)
                                    
                                    // Title and Subtitle
                                    VStack(alignment: .leading, spacing: 0.0) {
                                        Text("Study AI")
                                            .font(.custom(Constants.FontName.blackOblique, size: 14.0))
                                            .foregroundStyle(Colors.text)
                                        
                                        Text("Tap to Chat")
                                            .font(.custom(Constants.FontName.body, size: 24.0))
                                            .foregroundStyle(Colors.text)
                                    }
                                    
                                    Spacer()
                                    
                                    // Chevron
                                    Image(systemName: "chevron.right")
                                        .imageScale(.large)
                                        .foregroundStyle(Colors.text)
                                        .padding(.trailing)
                                }
                            }
                        }
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        .padding(.bottom, -2) // It adds extra padding to this one for some reason, so this is to get rid of it
                        .padding([.leading, .trailing])
                        
                        // New Chat Initial Suggestion Buttons
                        SuggestionsView(
                            suggestions: InitialSuggestions.initialSuggestions,
                            onSelect: { suggestion in
                                selectedSuggestion = suggestion
                            })
                        
                        // Assistants
                        HStack {
                            Text("Assistants")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                            
                            Spacer()
                            
                            Button(action: {
                                isShowingAssistantsView = true
                            }) {
                                Text("All Assistants \(Image(systemName: "chevron.right"))")
                                    .font(.custom(Constants.FontName.body, size: 17.0))
                            }
                        }
                        .padding(.top)
                        .padding([.leading, .trailing])
                        
                        // Assistants Display
                        AssistantsCategoryListView(selectedSortItem: $selectedAssistantSortItem)
                        
                        // Explore
                        HStack {
                            Text("Actions")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                            
                            Spacer()
                            
                            Button(action: {
                                isShowingExploreView = true
                            }) {
                                Text("All Actions \(Image(systemName: "chevron.right"))")
                                    .font(.custom(Constants.FontName.body, size: 17.0))
                            }
                        }
                        .padding(.top)
                        .padding([.leading, .trailing])
                        
                        // Explore Mini View
                        ExploreMiniView(
                            panelGroups: panelGroups,
                            presentingPanel: $presentingPanel)
                        
                        // History
                        HStack {
                            Text("History")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                            
                            Spacer()
                        }
                        .padding(.top)
                        .padding([.leading, .trailing])
                        
                        // Conversation List
                        VStack {
                            ConversationListContainer(presentingConversation: $presentingConversation)
                        }
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        .padding(.horizontal)
                    }
                    .padding([.top, .bottom])
                }
            }
            .scrollContentBackground(.hidden)
            .background(Colors.background)
            .navigationTitle("Chats")
            .fullScreenCover(isPresented: $isShowingCameraView, content: {
                ZStack {
                    CaptureCameraViewControllerRepresentable(
                        //                    isShowing: $isShowingCameraView,
                        reset: .constant(false), // TODO: Fix reset for capture camera view
                        withCropFrame: .constant(nil),
                        withImage: .constant(nil),
                        onAttach: { image, cropFrame, originalImage in
                            // Create converation, generate chat with selectedSuggestion and image, set conversation to new conversation
                            do {
                                // Create conversation
                                let conversation = try ConversationCDHelper.appendConversation(
                                    modelID: premiumUpdater.isPremium ? GPTModels.gpt4o.rawValue : GPTModels.gpt4oMini.rawValue,
                                    assistant: faceAssistant,
                                    in: viewContext)
                                
                                // Set presentingConversation to new conversation, shouldDoInitialChatGeneration to true, initialChatGenerationText to selectedSuggestion fullPromptString, initialChatGenerationImage to image, and initialchatGenerationImageURL to nil
                                self.presentingConversation = conversation
                                self.initialChatGenerationText = selectedSuggestion?.fullPromptString
                                self.initialChatGenerationImage = image
                                self.initialChatGenerationImageURL = nil
                            } catch {
                                // TODO: Handle Errors
                                print("Error appending conversation in ConversationCreationAssistantsView... \(error)")
                            }
                            
                            // Dismiss camera view
                            isShowingCameraView = false
                        },
                        onScan: { scanText in
                            // Create input with suggestion and scanText or just scanText if suggestion cannot be unwrapped or its fullPromptString is empty since fullString is not an optional so it doesn't need to be unwrapped just selectedSuggestion does lol ree aaaaa
                            let input: String = {
                                if let fullSuggestionString = selectedSuggestion?.fullPromptString, !fullSuggestionString.isEmpty {
                                    return fullSuggestionString + "\n\n" + scanText
                                }
                                
                                return scanText
                            }()
                            
                            // Create conversation, generate chat with selectedSuggestion and scanText, set conversation to new conversation
                            do {
                                // Craete conversation
                                let conversation = try ConversationCDHelper.appendConversation(
                                    modelID: premiumUpdater.isPremium ? GPTModels.gpt4o.rawValue : GPTModels.gpt4oMini.rawValue,
                                    assistant: faceAssistant,
                                    in: viewContext)
                                
                                // Set presentingConversation to new conversation, shouldDoInitialChatGeneration to true, initialChatGenerationText to input, initialChatGenerationImage to nil, and initialChatGenerationImageURL to nil
                                self.presentingConversation = conversation
                                self.initialChatGenerationText = input
                                self.initialChatGenerationImage = nil
                                self.initialChatGenerationImageURL = nil
                            } catch {
                                // TODO: Handle Errors
                                print("Error appending conversation in ConversationCreationAssistantsView... \(error)")
                            }
                            
                            // Dismiss camera view
                            isShowingCameraView = false
                        })
                    
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                isShowingCameraView = false
                            }) {
                                Text(Image(systemName: "xmark"))
                                    .font(.custom(Constants.FontName.body, size: 20.0))
                                    .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                    .padding()
                                    .background(Colors.foreground)
                                    .clipShape(Circle())
                            }
                            .padding()
                        }
                        
                        Spacer()
                    }
                }
                .ignoresSafeArea()
            })
            .navigationDestination(isPresented: isShowingPresentingConversation) {
                if let presentingConversation = presentingConversation {
                    ConversationViewContainer(
                        conversation: presentingConversation,
                        initialChatGenerationText: initialChatGenerationText,
                        initialChatGenerationImage: initialChatGenerationImage,
                        initialChatGenerationImageURL: initialChatGenerationImageURL,
                        onCreateConversation: { assistant in
                            // Do light haptic
                            HapticHelper.doLightHaptic()
                            
                            // Create new Conversation and set to conversation TODO: Better way of doing this
                            do {
                                let conversation = try ConversationCDHelper.appendConversation(
                                    modelID: presentingConversation.modelID ?? GPTModels.gpt4oMini.rawValue,
                                    assistant: assistant ?? presentingConversation.assistant,
                                    in: viewContext)
                                
                                self.presentingConversation = conversation
                            } catch {
                                // TODO: Handle Errors
                                print("Error appending Conversation in ConversationView... \(error)")
                            }
                        }
                    )
                }
            }
            .navigationDestination(isPresented: $isShowingExploreView) {
                if let panelGroups = panelGroups {
                    ExploreView(panelGroups: panelGroups)
                }
            }
            .navigationDestination(isPresented: isShowingPresentingPanelView) {
                if let presentingPanel = presentingPanel {
                    ExplorePanelView(panel: presentingPanel)
                }
            }
            .navigationDestination(isPresented: $isShowingSettingsView) {
                SettingsView()
            }
            .navigationDestination(isPresented: $isShowingFavoritesView) {
                FavoritesView(assistant: try? CurrentAssistantPersistence.getAssistant(in: viewContext))
            }
            .fullScreenCover(isPresented: $isShowingAssistantsView) {
                ConversationCreationAssistantsContainer(
                    isPresented: $isShowingAssistantsView,
                    presentingConversation: $presentingConversation)
            }
            .navigationDestination(isPresented: isPresentingAssistantSortItem) {
                if let selectedAssistantSortItem = selectedAssistantSortItem {
                    ConversationCreationAssistantsSortSpecFilteredView(
                        conversation: $presentingConversation,
                        isPresented: isPresentingAssistantSortItem,
                        selectedSortItem: selectedAssistantSortItem)
                    .padding()
                    .background(Colors.background)
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Colors.background, for: .navigationBar)
            .toolbar {
                SettingsToolbarItem(
                    elementColor: .constant(Colors.navigationItemColor),
                    placement: .topBarLeading,
                    tightenLeadingSpacing: true,
                    tightenTrailingSpacing: true,
                    action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Show Settings View
                        isShowingSettingsView = true
                    })
                
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("StudyAI")
                            .font(.custom(Constants.FontName.black, size: 24.0))
                            .foregroundStyle(Colors.navigationItemColor)
                    }
                }
                
                ShareToolbarItem(
                    elementColor: .constant(Colors.navigationItemColor),
                    placement: .topBarLeading,
                    tightenLeadingSpacing: true)
                
//                ToolbarItem(placement: .topBarTrailing) {
//                    EditButton()
//                        .tint(Colors.navigationItemColor)
//                        .font(.custom(Constants.FontName.black, size: 17.0))
//                        .padding(.top, 4)
//                        .padding(.trailing, premiumUpdater.isPremium ? 0.0 : -12.0)
//                        .onTapGesture {
//                            // Do light haptic
//                            HapticHelper.doLightHaptic()
//                        }
//                        .padding(.trailing, 4)
//                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowingFavoritesView = true
                    }) {
                        Text(Image(systemName: "heart"))
                            .font(.custom(Constants.FontName.medium, size: 19.0))
                            .foregroundStyle(Colors.navigationItemColor)
                    }
                    .padding(.horizontal, -4)
                }
                
                if !premiumUpdater.isPremium {
                    UltraToolbarItem()
                }
            }
            .onAppear {
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "\(Self.self)",
                                               AnalyticsParameterScreenClass: "\(Self.self)"])
            }
//            .onChange(of: faceAssistant) { newValue in
//                // If faceAssistant is changed and isShowingFaceAssistantSelectorView is true, then that means the user selected a new faceAssistant so close isShowingFaceAssistantSelectorView
//                if isShowingFaceAssistantSelectorView {
//                    self.isShowingFaceAssistantSelectorView = false
//                }
//            }
            .onChange(of: isShowingCameraView) { newValue in
                // If camera view is dismissed set selectedSuggestionsForCameraView to nil to allow for the camera to be reopened
                if !newValue {
                    selectedSuggestion = nil
                }
            }
            .onChange(of: presentingConversation) { newValue in
                // Reset initial chat values if newValue is nil
                if newValue == nil {
                    initialChatGenerationText = nil
                    initialChatGenerationImage = nil
                    initialChatGenerationImageURL = nil
                }
                
                // If presentingConversation can be unwrapped set it as ConversationResumingManager conversation
                if let newValue = newValue {
                    do {
                        try ConversationResumingManager.setConversation(newValue, in: viewContext)
                    } catch {
                        // TODO: Handle errors
                        print("Error obtaining permanent ID for conversation in MainView... \(error)")
                    }
                }
                
//                // If shouldDoInitialChatGeneration is true, do initial chat generation TODO: I put this here with a binding instead of onAppear or task because it was not getting called at the right times, seemingly the view was already loaded or not appearing to the user or something
//                if shouldDoInitialChatGeneration {
//                    Task {
//                        await doInitialChatGeneration()
//                    }
//                }
            }
            .onChange(of: selectedSuggestion) { newValue in
                // Create and set Conversation with faceAssistant and send Suggestion or show camera and send Suggestion
                if let suggestion = newValue {
                    // Create and set Conversation
                        if suggestion.requestsImageSend {
                            // If requests image send, open camera and generate the chat from there
                            isShowingCameraView = true
                        } else {
                            // If does not request image send, just create conversation, generate the chat right here, and set conversation to new conversation
                            do {
                                // Create conversation
                                let conversation = try ConversationCDHelper.appendConversation(
                                    modelID: premiumUpdater.isPremium ? GPTModels.gpt4o.rawValue : GPTModels.gpt4oMini.rawValue,
                                    assistant: faceAssistant,
                                    in: viewContext)
                                
                                // Set presentingConversation to new conversation, shouldDoInitialChatGeneration to true, initialChatGenerationText to suggestion fullPromptString, initialChatGenerationImage to nil, and initialChatGenerationImageURL to nil
                                self.presentingConversation = conversation
                                self.initialChatGenerationText = suggestion.fullPromptString
                                self.initialChatGenerationImage = nil
                                self.initialChatGenerationImageURL = nil
                            } catch {
                                // TODO: Handle Errors
                                print("Error appending Conversation in ConversationCreationAssistantsView... \(error)")
                            }
                        }
                }
            }
        }
    }
    
    func transitionToNewConversationIfNecessary() async {
        // TODO: Make this better, it's a little jumpy in the transition
        
        // Defer setting transitionToNewConversation to false to ensure it is always set when the function completes
        defer {
            transitionToNewConversation = false
        }
        
        // Ensure transitionToNewConversation is true, otherwise return
        guard transitionToNewConversation else {
            return
        }
        
        let conversation = Conversation(context: viewContext)
        conversation.conversationID = Constants.defaultConversationID
        conversation.behavior = nil
        
        await MainActor.run {
            do {
                try viewContext.save()
            } catch {
                // TODO: Handle errors
                print("Error saving new conversation in MainView... \(error)")
            }
            
            // Set animations to false and set presentingConversation to nil
            UIView.setAnimationsEnabled(false)
            
            presentingConversation = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: {
            // Set animations to false and set presentingConversation to conversation
            UIView.setAnimationsEnabled(false)
            
            presentingConversation = conversation
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            // Set animations back to true
            UIView.setAnimationsEnabled(true)
        })
    }
    
//    func doInitialChatGeneration() async {
//        // Generate Chat with Initial Chat Input, Image, and ImageURL as long as at least one can be unwrapped and is not empty
//        guard (initialChatGenerationText != nil && !initialChatGenerationText!.isEmpty) || (initialChatGenerationImage != nil) || (initialChatGenerationImageURL != nil && !initialChatGenerationImageURL!.isEmpty) else {
//            // Set shouldDoInitialChatGeneration to false TODO: Handle Errors if Necessary
//            DispatchQueue.main.async {
//                shouldDoInitialChatGeneration = false
//            }
//            
//            return
//        }
//        
//        // Unwrap presentingConversation
//        guard let presentingConversation = presentingConversation else {
//            // TODO: Handle Errors
//            print("Could not unwrap presentingConversation in MainView!")
//            return
//        }
//        
//        // Get and unwrap authToken
//        let authToken: String
//        do {
//            authToken = try await AuthHelper.ensure()
//        } catch {
//            // TODO: Handle errors
//            print("Error ensuring authToken in MainView... \(error)")
//            return
//        }
//        
//        // Generate chat
//        do {
//            try await conversationChatGenerator.generateChat(
//                input: initialChatGenerationText,
//                image: initialChatGenerationImage,
//                imageURL: initialChatGenerationImageURL,
//                conversation: presentingConversation,
//                authToken: authToken,
//                isPremium: premiumUpdater.isPremium,
//                remainingUpdater: remainingUpdater,
//                in: viewContext)
//        } catch {
//            // TODO: Handle Errors
//            print("Error generating chat in MainView... \(error)")
//        }
//        
//        // Set values and stuff to nil TODO: Maybe do this before generating the chat and set them to temp variables to generate the chat?
//        DispatchQueue.main.async {
//            shouldDoInitialChatGeneration = false
//            initialChatGenerationText = nil
//            initialChatGenerationImage = nil
//            initialChatGenerationImageURL = nil
//        }
//    }
    
}

#Preview {
    
    //    for i in 0..<10 {
    //        let conversation = Conversation(context: CDClient.mainManagedObjectContext)
    //        conversation.latestChatText = "Test\(i)"
    //
    //        try? CDClient.mainManagedObjectContext.save()
    //    }
    
    var panelGroups: [PanelGroup]? {
        if let panelJson = PanelPersistenceManager.get() {
            do {
                return try PanelParser.parsePanelGroups(fromJson: panelJson)
            } catch {
                // TODO: Handle errors if necessary
                print("Error parsing panel groups from panelJson in TabBar... \(error)")
            }
        }
        
        return nil
    }
    
    var assistant = try! CDClient.mainManagedObjectContext.fetch(Assistant.fetchRequest()).first!
    
    MainView(
        faceAssistant: .constant(assistant),
        panelGroups: .constant(panelGroups!),
        presentingConversation: .constant(nil))
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    .environmentObject(PremiumUpdater())
    .environmentObject(ProductUpdater())
    .environmentObject(RemainingUpdater())
}
