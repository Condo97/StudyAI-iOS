////
////  TabBar.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 10/22/23.
////
//
//import FaceAnimation
//import SwiftUI
//
//struct TabBar: View, KeyboardReadable {
//    
//    @ObservedObject var activeAssistantUpdater: ActiveAssistantUpdater
//    
//    private var faceAnimationUpdater: FaceAnimationUpdater
//    
////    @EnvironmentObject private var activeAssistantUpdater: ActiveAssistantUpdater
//    @EnvironmentObject private var premiumUpdater: PremiumUpdater
//    @EnvironmentObject private var productUpdater: ProductUpdater
//    @EnvironmentObject private var remainingUpdater: RemainingUpdater
//    
//    
//    @Environment(\.managedObjectContext) var viewContext
//    @State private var selectedTab: Tab = .chat
//    
//    @State private var isShowingGPTModelSelectionView: Bool = false
//    @State private var isShowingPromoSendImagesView: Bool = false
//    
//    @State private var isKeyboardVisible: Bool = false
//    
//    @State private var pushToLatestConversationOrClose: Bool = true
//    
//    @State private var alertShowingExploreUnderMaintenance: Bool = false
//    
//    @State private var willMakeChatViewActive: Bool = false
//    
//    @State private var faceAnimationViewRepresentable: FaceAnimationViewRepresentable?
//    
//    @State private var presentingConversation: Conversation?
//    
//    private let buttonWidth: CGFloat = 58.0
//    
//    private let faceEdgeInset: CGFloat = 8.0
//    private static let faceFrameDiameter: CGFloat = 104.0
//    private let faceFrameDiameter = faceFrameDiameter
//    private let faceBackgroundDiameterScaleFactor: CGFloat = 1.2
//    private let faceButtonBottomOffset: CGFloat = 40.0
//    
//    private var panelGroups: [PanelGroup]? {
//        if let panelJson = PanelPersistenceManager.get() {
//            do {
//                return try PanelParser.parsePanelGroups(fromJson: panelJson)
//            } catch {
//                // TODO: Handle errors if necessary
//                print("Error parsing panel groups from panelJson in TabBar... \(error)")
//            }
//        }
//        
//        return nil
//    }
//    
//    init(activeAssistantUpdater: ActiveAssistantUpdater) {
//        self.activeAssistantUpdater = activeAssistantUpdater
//        
//        self.faceAnimationUpdater = FaceAnimationUpdater(faceAnimationViewRepresentable: nil)
//        
//        setFaceAnimationViewRepresentable()
//        
//        UITabBar.appearance().isHidden = true
//        
//        do {
//            self._presentingConversation = State(initialValue: try ConversationCDHelper.getConversation(in: CDClient.mainManagedObjectContext))
//        } catch {
//            // TODO: Handle errors
//            print("Error getting Conversation in TabBar... \(error)")
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            // Tab Bar Selection
//            VStack {
//                VStack {
//                    TabView(selection: $selectedTab) {
//                        ZStack {
//                            if let panelGroups = panelGroups {
//                                NavigationStack {
//                                    ExploreView(panelGroups: panelGroups)
//                                }
//                            } else {
//                                MaintenanceView()
//                            }
//                        }
//                        .tag(Tab.explore)
////                        .padding(.bottom, 80)
//                        
//                        NavigationStack {
//                            ConversationView(
//                                isShowingGPTModelSelectionView: $isShowingGPTModelSelectionView,
//                                pushToLatestConversationOrClose: $pushToLatestConversationOrClose)
////                            ChatViewContainer(
////                                conversation: $presentingConversation,
////                                isShowingGPTModelSelectionView: $isShowingGPTModelSelectionView,
////                                shouldShowFirstConversationChats: false,
////                                activeAssistantUpdater: activeAssistantUpdater)
//                        }
//                        .tag(Tab.chat)
//    //                    .padding(.bottom, 80)
//                        
//                        NavigationStack {
//                            ConversationView(
//                                isShowingGPTModelSelectionView: $isShowingGPTModelSelectionView,
//                                pushToLatestConversationOrClose: .constant(false))
//                        }
//                        .tag(Tab.essay)
////                        .padding(.bottom, 80)
//                    }
//                    
//                    VStack(spacing: 0.0) {
//        //                Spacer()
//                        
//                        ZStack {
//                            VStack {
//                                Spacer()
//                                Colors.bottomBarBackgroundColor
//        //                            .ignoresSafeArea()
//                                    .frame(height: 64.0)
//                            }
//                            
//                            HStack(alignment: .bottom) {
//                                HStack {
//                                    Spacer()
//                                    createButton
//                                        .frame(width: buttonWidth)
//                                    Spacer()
//                                }
//                                
//                                HStack {
//                                    writeButton
//                                        .offset(y: -2)
//                                }
//                                
//                                HStack {
//                                    Spacer()
//                                    essayButton
//                                        .frame(width: buttonWidth)
//                                    Spacer()
//                                }
//                            }
//        //                    .ignoresSafeArea()
//                        }
//                        .frame(height: 120.0)
//                        .background(.clear)
//                        
//                        Colors.bottomBarBackgroundColor
//                            .ignoresSafeArea()
//                            .frame(height: 14.0)
//                    }
//                    .padding(.top, -64)
//
//                }
//                .ignoresSafeArea(.keyboard, edges: .bottom)
//                .ignoresSafeArea(.keyboard, edges: .bottom)
////                .padding(.bottom, 80)
//            }
//            
//            /*** Popups ***/
//            
//            // Blur Background View
//            if isShowingGPTModelSelectionView || isShowingPromoSendImagesView {
//                MaterialView(.systemMaterialDark)
//                    .zIndex(1.0)
//                    .animation(.easeInOut, value: isShowingGPTModelSelectionView)
//                    .transition(.opacity)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation {
//                            isShowingGPTModelSelectionView = false
//                        }
//                    }
//            }
//            
//            // GPT Model Selection View
//            if isShowingGPTModelSelectionView {
//                VStack {
//                    Spacer()
//                    GPTModelSelectionView(isShowing: $isShowingGPTModelSelectionView)
//                    .background(FullScreenCoverBackgroundCleanerView())
//                }
//                .zIndex(2.0)
//                .padding()
//                .animation(.easeInOut, value: isShowingGPTModelSelectionView)
//                .transition(.move(edge: .bottom))
//                .ignoresSafeArea()
//            }
//            
//            // Promo Send Images View
//            if isShowingPromoSendImagesView {
//                VStack {
//                    PromoSendImagesView(
//                        isShowing: $isShowingPromoSendImagesView, pressedScan: {
//                            
//                        })
//                }
//            }
//            
//            
//        }
//        .onAppear {
//            setFaceAnimationViewRepresentable()
//            
//            faceAnimationUpdater.faceAnimationViewRepresentable = faceAnimationViewRepresentable
//        }
//        .environmentObject(faceAnimationUpdater)
//        .onChange(of: selectedTab) { value in
//            // Change faceIdleAnimation
//            switch value {
//            case .explore:
//                faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.deselected)
//            case .chat:
//                faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
//            case .essay:
//                faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.deselected)
//            }
//        }
//        .onChange(of: willMakeChatViewActive) { value in
//            // Set chat view to active
//            selectedTab = .chat
//            
//            // Set willMakeChatViewActive to false
//            willMakeChatViewActive = false
//        }
//        .onReceive(keyboardPublisher, perform: { value in
//            isKeyboardVisible = value
//        })
//        .onAppear {
//            // Set face idle animation to smile
//            faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
//        }
//        .alert("Under Maintenance", isPresented: $alertShowingExploreUnderMaintenance, actions: {
//            Button("Close", role: .cancel, action: {
//                
//            })
//        }) {
//            Text("The Create tab is under maintenance. Please check back later.")
//        }
//    }
//    
//    var createButton: some View {
//        ZStack {
//            Button(action: {
//                // Do light hpatic
//                HapticHelper.doLightHaptic()
//                
//                // Show alert if panelGroups is nil, otherwise select explore tab
//                withAnimation(.none) {
//                    if panelGroups == nil {
//                        // Show under maintenance alert
//                        alertShowingExploreUnderMaintenance = true
//                    } else {
//                        // Set selected tab to explore
//                        self.selectedTab = .explore
//                    }
//                }
//            }) {
//                VStack(spacing: 0.0) {
//                    Spacer()
//                    
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 14.0)
//                            .foregroundStyle(Colors.elementTextColor)
//                            .opacity(selectedTab == .explore ? 1.0 : 0.0)
//                        
//                        VStack(spacing: 0.0) {
//                            Image(systemName: "sparkles")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .foregroundStyle(selectedTab == .explore ? Colors.elementBackgroundColor : Colors.elementTextColor)
//                                .padding(.top, 2)
//                            
//                            Text("More")
//                                .font(.custom(Constants.FontName.body, size: 16.0))
//                                .foregroundStyle(selectedTab == .explore ? Colors.elementBackgroundColor : Colors.elementTextColor)
//                        }
//                        .padding(4)
//                    }
//                    .frame(width: 80.0, height: 60.0)
//                }
//            }
//            .opacity(panelGroups == nil ? 0.4 : 1.0)
//        }
//    }
//    
//    var writeButton: some View {
//        ZStack {
//            ZStack {
//                // Circle assistant background
//                Circle()
//                    .fill(selectedTab == .chat ? Colors.elementTextColor : Colors.elementBackgroundColor)
//                    .frame(width: faceFrameDiameter)// * faceBackgroundDiameterScaleFactor)
//                if selectedTab != .chat {
//                    let lineWidth = 2.0
//                    Circle()
//                        .stroke(Colors.elementTextColor, lineWidth: lineWidth)
//                        .frame(width: faceFrameDiameter)// * faceBackgroundDiameterScaleFactor - lineWidth)
//                }
//                
//                // Assistant display
////                if faceAnimationViewRepresentable != nil {
//                // Face
//                if let faceStyle = activeAssistantUpdater.assistantSpec?.faceStyle {
//                    // TODO: This removes animations... they will have to be set somehow else
//                    FaceAnimationViewRepresentable(
//                        frame: CGRect(x: 0, y: 0, width: faceFrameDiameter, height: faceFrameDiameter),
//                        showsMouth: faceStyle.showsMouth,
//                        noseImageName: faceStyle.noseImageName,
//                        faceImageName: faceStyle.backgroundImageName,
//                        facialFeaturesScaleFactor: 0.72,
//                        color: selectedTab == .chat ? UIColor(Colors.elementBackgroundColor) : UIColor(Colors.elementTextColor),
//                        startAnimation: SmileCenterFaceAnimation(duration: 0.0))
////                    faceAnimationViewRepresentable
////                        .onChange(of: selectedTab, perform: { value in
////                            faceAnimationViewRepresentable?.setColor(selectedTab == .chat ? UIColor(Colors.elementBackgroundColor) : UIColor(Colors.elementTextColor))
////                        })
//                    //                        .tint(selectedTab == .chat ? Colors.elementBackgroundColor : Colors.elementTextColor)
//                        .frame(width: faceFrameDiameter, height: faceFrameDiameter)
//                    //                } else if let emoji = activeAssistantUpdater.assistantSpec?.emoji {
//                    //                    // Emoji
//                    //                    Text(emoji)
//                    //                        .font(.custom(Constants.FontName.body, size: 28.0))
//                    //                } else {
//                    //                    // TODO: Title
//                    //                }
//                } else if let image = activeAssistantUpdater.assistantSpec?.image {
//                    // TODO: Image implementation
//                    
//                } else if let emoji = activeAssistantUpdater.assistantSpec?.emoji,
//                          let emojiBackgroundColor = activeAssistantUpdater.assistantSpec?.emojiBackgroundColor {
//                    ZStack {
//                        Text(emoji)
//                            .font(.custom(Constants.FontName.body, size: 48.0))
//                    }
//                    .frame(width: faceFrameDiameter / 1.5, height: faceFrameDiameter / 1.5)
//                    .background(Color(emojiBackgroundColor))
//                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                }
//            }
//            .onTapGesture {
//                // Do light haptic
//                HapticHelper.doLightHaptic()
//                
//                // If not selected set the selectedTab to chat, otherwise set pushToLatestConversationOrClose to true
//                if selectedTab != .chat {
//                    withAnimation(.none) {
//                        self.selectedTab = .chat
//                    }
//                } else {
//                    pushToLatestConversationOrClose = true
//                }
//            }
//        }
//    }
//    
//    var essayButton: some View {
//        ZStack {
//            Button(action: {
//                // Do light haptic
//                HapticHelper.doLightHaptic()
//                
//                // Set selected tab to essay
//                withAnimation(.none) {
//                    self.selectedTab = .essay
//                }
//            }) {
//                VStack(spacing: 0.0) {
//                    Spacer()
//                    
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 14.0)
//                            .foregroundStyle(Colors.elementTextColor)
//                            .opacity(selectedTab == .essay ? 1.0 : 0.0)
//                        
//                        VStack(spacing: 0.0) {
//                            Image(systemName: "clock.arrow.circlepath")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .foregroundStyle(selectedTab == .essay ? Colors.elementBackgroundColor : Colors.elementTextColor)
//                                .padding(.top, 2)
//                            
//                            Text("History")
//                                .font(.custom(Constants.FontName.body, size: 16.0))
//                                .foregroundStyle(selectedTab == .essay ? Colors.elementBackgroundColor : Colors.elementTextColor)
//                        }
//                        .padding(4)
//                    }
//                    .frame(width: 80.0, height: 60.0)
//                    
//                    
////                    Image(selectedTab == .essay ? Constants.ImageName.BottomBarImages.essayBottomButtonSelected : Constants.ImageName.BottomBarImages.essayBottomButtonNotSelected)
////                        .resizable()
////                        .aspectRatio(contentMode: .fit)
////                        .foregroundStyle(Colors.elementTextColor)
//                }
//            }
//        }
//    }
//    
//    func setFaceAnimationViewRepresentable() {
//        if let faceStyle = activeAssistantUpdater.assistantSpec?.faceStyle {
//            DispatchQueue.main.async {
//                self.faceAnimationViewRepresentable = FaceAnimationViewRepresentable(
//                    frame: CGRect(x: 0, y: 0, width: faceFrameDiameter, height: faceFrameDiameter),
//                    showsMouth: faceStyle.showsMouth,
//                    noseImageName: faceStyle.noseImageName,
//                    faceImageName: faceStyle.backgroundImageName,
//                    facialFeaturesScaleFactor: 0.72,
//                    color: UIColor(Colors.elementBackgroundColor),
//                    startAnimation: SmileCenterFaceAnimation(duration: 0.0)
//                )
//                
//                self.faceAnimationViewRepresentable?.setIdleAnimations(RandomFaceIdleAnimationSequence.smile)
//            }
//        }
//    }
//    
//}
//
//@available(iOS 17.0, *)
//#Preview(traits: .sizeThatFitsLayout) {
////    VStack {
////        Spacer()
//        
//    TabBar(activeAssistantUpdater: ActiveAssistantUpdater(managedObjectContext: CDClient.mainManagedObjectContext))
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//        .environmentObject(PremiumUpdater())
//        .environmentObject(ProductUpdater())
//        .environmentObject(RemainingUpdater())
////    }
////    .ignoresSafeArea()
//}
