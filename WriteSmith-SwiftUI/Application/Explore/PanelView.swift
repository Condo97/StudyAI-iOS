//
//  PanelView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct PanelView: View {
    
    @Binding var panel: Panel
    @Binding var isLoading: Bool
    @State var buttonText: String
    var onGenerate: (_ finalizedPrompt: String) -> Void
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
//    @StateObject private var exploreChatGenerator = ExploreChatGenerator()
    
    @State private var finalizedPrompt: String?
    
    @State private var alertShowingEmptyRequiredFields: Bool = false
    
    @State private var isShowingExploreChatsDisplayView: Bool = false
    @State private var isShowingInterstitial: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack(spacing: 16.0) {
                    if !premiumUpdater.isPremium {
                        BannerView(bannerID: Keys.Ads.Banner.panelView)
                    }
                    
                    HeaderPanelComponentView(
                        imageName: $panel.imageName,
                        emoji: $panel.emoji,
                        title: $panel.title,
                        description: $panel.description)
                    .padding()
                    
                    ForEach($panel.components) { $component in
                        switch component.content {
                        case .attachment(let attachmentPanelComponentContent):
                            AttachmentPanelComponentView(
                                component: $component,
                                attachmentComponentContent: attachmentPanelComponentContent)
                            .padding([.leading, .trailing])
                        case .dropdown(let dropdownPanelComponentContent):
                            DropdownPanelComponentView(
                                component: $component,
                                dropdownComponentContent: dropdownPanelComponentContent)
                            .padding([.leading, .trailing])
                        case .textField(let textFieldPanelComponentContent):
                            TextFieldPanelComponentView(
                                component: $component,
                                textFieldComponentContent: textFieldPanelComponentContent)
                            .padding([.leading, .trailing])
                        }
                    }
                }
                .padding(.bottom, 190)
            }
            
            VStack(spacing: 0.0) {
                Spacer()
                
                ZStack {
                    // Generate or Next or Whatever buttonText is Button
                    KeyboardDismissingButton(action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Ensure finalizedPrompt can be unwrapped, otherwise show empty fields alert and return
                        guard let finalizedPrompt = finalizedPrompt else {
                            alertShowingEmptyRequiredFields = true
                            return
                        }
                        
                        // Call onGenerate with finalizedPrompt
                        onGenerate(finalizedPrompt)
                        
//                        // Show interstitial if not premium
//                        if !premiumUpdater.isPremium {
//                            isShowingInterstitial = true
//                        }
//                        
//                        // Generate
//                        Task {
//                            do {
//                                try await exploreChatGenerator.generateExplore(
//                                    input: finalizedPrompt,
//                                    image: nil, // TODO: Add image functionality
//                                    imageURL: nil, // TODO: Add image URL functionality
//                                    isPremium: premiumUpdater.isPremium,
//                                    remainingUpdater: remainingUpdater)
//                            }
//                        }
                    }) {
                        ZStack {
                            HStack {
                                Spacer()
                                Text(buttonText)
                                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                
                                if isLoading {
                                    ProgressView()
                                        .tint(Colors.elementTextColor)
                                } else {
                                    Text(Image(systemName: "chevron.right"))
                                        .font(.custom(Constants.FontName.body, size: 17.0))
                                }
                            }
                        }
                    }
                    .foregroundStyle(Colors.elementTextColor)
                    .padding()
                    .background(Colors.buttonBackground)
                    .opacity(finalizedPrompt == nil || isLoading ? 0.4 : 1.0)
                    .background(Colors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0)) // Was 24 and it looked pretty sleek
                    .padding()
                    .padding(.bottom, 40)
                    .disabled(finalizedPrompt == nil || isLoading)
                }
                .background(
                    VStack(spacing: 0.0) {
                        LinearGradient(colors: [Colors.background, .clear], startPoint: .bottom, endPoint: .top)
                            .frame(height: 40.0)
                        Colors.background
                    }
                        .ignoresSafeArea()
                )
            }
        }
        .background(Colors.background)
        .background(
            InterstitialView(interstitialID: Keys.Ads.Interstitial.panelView, disabled: $premiumUpdater.isPremium, isPresented: $isShowingInterstitial))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .toolbar {
            ShareToolbarItem(
                elementColor: .constant(Colors.navigationItemColor),
                placement: .topBarLeading,
                tightenLeadingSpacing: true)
            
            ToolbarItem(placement: .principal) {
                ZStack {
                    Text("StudyAI")
                        .font(.custom(Constants.FontName.black, size: 24.0))
                        .foregroundStyle(Colors.navigationItemColor)
                }
            }
            
            if !premiumUpdater.isPremium {
                UltraToolbarItem()
            }
        }
        .keyboardDismissingTextFieldToolbar("Done", color: Colors.buttonBackground)
        .onChange(of: panel.components) { newComponents in
            updateFinalizedPrompt()
        }
//        .onReceive(exploreChatGenerator.$generatedChats, perform: { generatedChats in
//            if generatedChats.count > 0, !generatedChats[0].chat.isEmpty {
//                isShowingExploreChatsDisplayView = true
//            }
//        })
//        .navigationDestination(isPresented: $isShowingExploreChatsDisplayView, destination: {
//            ExploreChatsDisplayView(chats: $exploreChatGenerator.generatedChats)
//        })
        .alert("Empty Required Fields", isPresented: $alertShowingEmptyRequiredFields, actions: {
            Button("Close", role: .cancel, action: {
                
            })
        }) {
            Text("Please make sure all required fields have text.")
        }
    }
    
    private func updateFinalizedPrompt() {
        // TODO: I don't think that it's using the "prompt" text when creating the finalized prompt, so maybe that's something that needs to be fixed?
        
        let newLineSeparator = ", "
        
        // Build completeFinalizedPrompt starting from prmopt, ensuring that all required values' finalizedPrompts are not nil and return
        var completeFinalizedPrompt = panel.prompt == nil ? "" : "\(panel.prompt!)\n"
        
        for i in 0..<panel.components.count {
            let component = panel.components[i]
            
            // Unswrap finalizedPrompt, otherwise either return nil or continue if required or not
            guard let finalizedPrompt = component.finalizedPrompt, !finalizedPrompt.isEmpty else {
                // If required set finalizedPrompt to nil and return
                if component.requiredUnwrapped {
                    finalizedPrompt = nil
                    return
                }
                
                // Otherwise, continue
                continue
            }
            
            // Append to completeFinalizedPrompt
            completeFinalizedPrompt.append(finalizedPrompt)
            
            // If not the last index in panel.components, append the comma separator
            if i < panel.components.count - 1 {
                completeFinalizedPrompt.append(newLineSeparator)
            }
        }
        
        // Ensure completeFinalizedPrompt is not empty, otherwise set to nil and return TODO: Is this good here? Maybe I need to rework this function? I don't think it's great to be using nil and switching between nil and empty.. it should just be one state, the empty state I think, not the nil state ever..
        guard !completeFinalizedPrompt.isEmpty else {
            finalizedPrompt = nil
            return
        }
        
        finalizedPrompt = completeFinalizedPrompt
        
        print("Finalized Prompt: \(finalizedPrompt)")
    }
    
}

//#Preview {
//    NavigationStack {
//        PanelView(panel: .constant(Panel(
//            emoji: "🎶",
//            title: "The title",
//            description: "The description",
//            prompt: "The prompt",
//            components: [
//                PanelComponent(
//                    componentID: "1",
//                    content: .dropdown(
//                        DropdownPanelComponentContent(
//                            placeholder: "Placeholder",
//                            options: [
//                                "Option 1",
//                                "Option 2",
//                                "Option 3"
//                            ])),
//                    titleText: "Title Text",
//                    detailTitle: "Detail Title",
//                    detailText: "Detail Text",
//                    promptPrefix: "Prompt Prefix",
//                    required: true),
//                PanelComponent(
//                    componentID: "2",
//                    content: .textField(
//                        TextFieldPanelComponentContent(
//                            placeholder: "placeholder"
//                        )),
//                    titleText: "Text Field Title Text",
//                    detailTitle: "Text Field Detail Title",
//                    detailText: "Text Field Detail Text",
//                    promptPrefix: "Text Field Prompt Prefix",
//                    required: false),
//                PanelComponent(
//                    componentID: "3",
//                    content: .dropdown(
//                        DropdownPanelComponentContent(
//                            placeholder: "Placeholder",
//                            options: [
//                                "Option 1",
//                                "Option 2",
//                                "Option 3"
//                            ])),
//                    titleText: "Title Text",
//                    detailTitle: "Detail Title",
//                    detailText: "Detail Text",
//                    promptPrefix: "Prompt Prefix",
//                    required: true),
//                PanelComponent(
//                    componentID: "4",
//                    content: .textField(
//                        TextFieldPanelComponentContent(
//                            placeholder: "placeholder"
//                        )),
//                    titleText: "Text Field Title Text",
//                    detailTitle: "Text Field Detail Title",
//                    detailText: "Text Field Detail Text",
//                    promptPrefix: "Text Field Prompt Prefix",
//                    required: false),
//                PanelComponent(
//                    componentID: "5",
//                    content: .dropdown(
//                        DropdownPanelComponentContent(
//                            placeholder: "Placeholder",
//                            options: [
//                                "Option 1",
//                                "Option 2",
//                                "Option 3"
//                            ])),
//                    titleText: "Title Text",
//                    detailTitle: "Detail Title",
//                    detailText: "Detail Text",
//                    promptPrefix: "Prompt Prefix",
//                    required: true),
//                PanelComponent(
//                    componentID: "6",
//                    content: .textField(
//                        TextFieldPanelComponentContent(
//                            placeholder: "placeholder"
//                        )),
//                    titleText: "Text Field Title Text",
//                    detailTitle: "Text Field Detail Title",
//                    detailText: "Text Field Detail Text",
//                    promptPrefix: "Text Field Prompt Prefix",
//                    required: false),
//                PanelComponent(
//                    componentID: "7",
//                    content: .dropdown(
//                        DropdownPanelComponentContent(
//                            placeholder: "Placeholder",
//                            options: [
//                                "Option 1",
//                                "Option 2",
//                                "Option 3"
//                            ])),
//                    titleText: "Title Text",
//                    detailTitle: "Detail Title",
//                    detailText: "Detail Text",
//                    promptPrefix: "Prompt Prefix",
//                    required: true),
//                PanelComponent(
//                    componentID: "8",
//                    content: .textField(
//                        TextFieldPanelComponentContent(
//                            placeholder: "placeholder"
//                        )),
//                    titleText: "Text Field Title Text",
//                    detailTitle: "Text Field Detail Title",
//                    detailText: "Text Field Detail Text",
//                    promptPrefix: "Text Field Prompt Prefix",
//                    required: false)
//            ])),
//                  isLoading: .constant(false),
//                  buttonText: "Generate",
//                  onGenerate: { finalizedPrompt in
//            
//        })
//        .background(Colors.background)
//    }
//    .environmentObject(RemainingUpdater())
//    .environmentObject(PremiumUpdater())
//    .environmentObject(ProductUpdater())
//}
