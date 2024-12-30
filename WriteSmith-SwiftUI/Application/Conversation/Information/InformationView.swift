//
//  InformationView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/28/24.
//

import CoreData
import Foundation
import SwiftUI

struct InformationView: View {
    
    @Binding var isPresented: Bool
    var conversation: Conversation
    
    
    enum ClearStates {
        case deselected
        case selectOnce
        case selectTwice
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @Namespace private var namespace
    
    @State private var editedPromptText: String = ""
    @State private var selectedModel: GPTModels?
    
    @State private var isShowingBehaviorInfo: Bool = false
    @State private var isShowingEditPromptView: Bool = false
    @State private var isShowingFavoritesView: Bool = false
    @State private var isShowingKeepInMindView: Bool = false
    @State private var isShowingPoweredByLearnMoreView: Bool = false
    @State private var isShowingUltraView: Bool = false
    
    @State private var isDisplayingPronounsDisplay: Bool = false
    
    @State private var isToggledEnableTextFormatting: Bool = false
    
    var isToggledEnableGoogleSearchUniversal: Binding<Bool> {
        Binding(
            get: {
                !UserDefaults.standard.bool(forKey: Constants.UserDefaults.googleSearchDisabled)
            },
            set: { value in
                UserDefaults.standard.set(!value, forKey: Constants.UserDefaults.googleSearchDisabled)
            })
    }
    
    
    var body: some View {
        VStack(spacing: 16.0) {
//            // Assistant Display
//            assistantDisplay
//            
//            // Name
//            if let name = conversation.assistant?.name {
//                Text(name)
//                    .font(.custom(Constants.FontName.black, size: 28.0))
//                    .foregroundStyle(Colors.text)
//            }
//            
//            // Description
//            if let description = conversation.assistant?.assistantDescription {
//                Text(description)
//                    .multilineTextAlignment(.center)
//                    .font(.custom(Constants.FontName.body, size: 17.0))
//                    .foregroundStyle(Colors.text)
//            }
            
            // Keep in Mind Display
            keepInMindButton
            
            // Favorites Display
            favoritesButton
            
            // Prompt Display
            promptDisplay
            
            // Powered By Display
            poweredByDisplay
            
            // Model Settings Toggles
            modelSettingsToggles
            
//            // Pronouns Display
//            pronounsDisplay
        }
        .onAppear {
            // Set selectedModel
            self.selectedModel = GPTModels.from(id: conversation.modelID ?? "") ?? GPTModels.gpt4oMini
            
            // Set isToggledEnableTextFormatting
            self.isToggledEnableTextFormatting = !conversation.textFormattingDisabled
        }
        .ultraViewPopover(isPresented: $isShowingUltraView)
        .clearFullScreenCover(isPresented: $isShowingEditPromptView) {
            EditPromptView(editedPromptText: $editedPromptText,
                           onClose: {
                // Close alert
                self.isShowingEditPromptView = false
            },
                           onSubmit: {
                // Close alert, set assistant prompt text to editedPromptText, and save
                self.isShowingEditPromptView = false
                
                self.conversation.behavior = editedPromptText
                
                do {
                    try self.viewContext.performAndWait {
                        try self.viewContext.save()
                    }
                } catch {
                    print("Error saving viewContext in AssistantInformationView... \(error)")
                }
            })
        }
        .clearFullScreenCover(isPresented: $isShowingPoweredByLearnMoreView) {
            PoweredByLearnMoreView(isPresented: $isShowingPoweredByLearnMoreView)
                .padding()
        }
        .clearFullScreenCover(isPresented: $isShowingBehaviorInfo) {
            BehaviorInfoView(isPresented: $isShowingBehaviorInfo)
                .frame(maxWidth: 500.0)
                .padding()
                .background(Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding()
        }
        .fullScreenCover(isPresented: $isShowingFavoritesView) {
            NavigationStack {
                ChatListContainer(
                    emptyTitleText: Text("No Favorites \(Image(systemName: "heart.fill"))"),
                    emptyDescriptionText: Text("Tap and Hold a Chat Bubble to add it to Favorites."),
                    chats: FetchRequest<Chat>(
                        sortDescriptors: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)],
                        predicate: NSPredicate(format: "%K = %@ and %K = %d", #keyPath(Chat.conversation), conversation, #keyPath(Chat.favorited), true),
                        animation: .default))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Colors.background, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                                isShowingFavoritesView = false
                        }) {
                            Text("Close")
                        }
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(Colors.navigationItemColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Favorites")
                            .font(.custom(Constants.FontName.black, size: 24.0))
                            .foregroundStyle(Colors.navigationItemColor)
                    }
                }
            }
            .padding([.leading, .trailing])
            .background(Colors.background)
        }
        .fullScreenCover(isPresented: $isShowingKeepInMindView) {
            NavigationStack {
                ChatListContainer(
                    emptyTitleText: Text("No Keep In Mind \(Image(systemName: "pin.fill"))"),
                    emptyDescriptionText: Text("Tap and Hold a Chat Bubble to Keep in Mind."),
                    chats: FetchRequest<Chat>(
                        sortDescriptors: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)],
                        predicate: NSPredicate(format: "%K = %@ and %K = %d", #keyPath(Chat.conversation), conversation, #keyPath(Chat.keepInMind), true),
                        animation: .default))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Colors.background, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            isShowingKeepInMindView = false
                        }) {
                            Text("Close")
                        }
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(Colors.navigationItemColor)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Keep in Mind")
                            .font(.custom(Constants.FontName.black, size: 24.0))
                            .foregroundStyle(Colors.navigationItemColor)
                    }
                }
            }
            .padding([.leading, .trailing])
            .background(Colors.background)
        }
//        .scrollDismissesKeyboard(.immediately)
//        .overlay {
//            VStack {
//                HStack {
//                    Spacer()
//                    
//                    Button(action: {
//                        self.isPresented = false
//                    }) {
//                        Text(Image(systemName: "chevron.down"))
//                            .font(.custom(Constants.FontName.body, size: 24.0))
//                    }
//                    .padding(.trailing)
//                    .foregroundStyle(Colors.buttonBackground)
//                }
//                
//                Spacer()
//            }
//            .padding()
//        }
    }
    
//    var assistantDisplay: some View {
//        ZStack {
//            if let faceStyle = conversation.assistant?.faceStyle {
//                ZStack {
//                    FaceAnimationViewRepresentable(
//                        frame: CGRect(x: 0, y: 0, width: faceFrameDiameter, height: faceFrameDiameter),
//                        showsMouth: faceStyle.showsMouth,
//                        noseImageName: faceStyle.noseImageName,
//                        faceImageName: faceStyle.backgroundImageName,
//                        facialFeaturesScaleFactor: 0.72,
//                        color: UIColor(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor),
//                        startAnimation: SmileCenterFaceAnimation(duration: 0.0))
//                    .frame(width: faceFrameDiameter, height: faceFrameDiameter)
//                    .padding([.top, .bottom], -8)
//                }
//                .padding()
//                .background(Colors.foreground)
//                .clipShape(RoundedRectangle(cornerRadius: 14.0))
//            } else if let uiImage = conversation.assistant?.uiImage {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: faceFrameDiameter)
//            } else if let emoji = conversation.assistant?.emoji {
//                Text(emoji)
//                    .font(.custom(Constants.FontName.body, size: 68.0))
//                    .frame(width: faceFrameDiameter, height: faceFrameDiameter)
//                    .padding()
//                    .background(Colors.foreground)
//                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
//            } else {
//                Text("No Assistant")
//            }
//        }
//    }
    
    var favoritesButton: some View {
        VStack {
            Button(action: {
                isShowingFavoritesView = true
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                    
                    Text("Favorites")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
            }
            .font(.custom(Constants.FontName.body, size: 17.0))
            .padding()
            .foregroundStyle(Colors.text)
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
    }
    
    var keepInMindButton: some View {
        VStack {
            Button(action: {
                isShowingKeepInMindView = true
            }) {
                HStack {
                    Image(systemName: "pin.fill")
                    
                    Text("Keep in Mind")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
            }
            .font(.custom(Constants.FontName.body, size: 17.0))
            .padding()
            .foregroundStyle(Colors.text)
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
    }
    
    var promptDisplay: some View {
        VStack(spacing: 8.0) {
            HStack {
                Text("Behavior")
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                
                Button("\(Image(systemName: "info.circle"))") {
                    isShowingBehaviorInfo = true
                }
                
                Spacer()
            }
            
            Button(action: {
                editedPromptText = conversation.behavior ?? ""
                isShowingEditPromptView = true
            }) {
                VStack(alignment: .leading) {
                    ZStack {
                        HStack {
                            Spacer()
                            
                            if let systemPrompt = conversation.behavior {
                                Text(systemPrompt)
                                    .font(.custom(Constants.FontName.body, size: 14.0))
                            } else {
                                Text("Tap to Set Behavior")
                                    .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text(Image(systemName: "pencil.line"))
                        }
                        .padding(8)
                    })
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .foregroundStyle(Colors.text)
            }
        }
    }
    
    var poweredByDisplay: some View {
        VStack(spacing: 8.0) {
            HStack {
                Text("Powered By")
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                
                Button("\(Image(systemName: "info.circle"))") {
                    isShowingPoweredByLearnMoreView = true
                }
                
                Spacer()
            }
            
            HStack {
                // Free Model Button
                Button(action: {
                    // Set selectedModel to GPT4o Mini
                    withAnimation {
                        self.selectedModel = .gpt4oMini
                    }
                    
                    // Set currentChatModel in GPTModelHelper to gpt4oMini
                    GPTModelHelper.currentChatModel = .gpt4oMini
                    
                    // Set modelName in CoreData
                    self.conversation.modelID = GPTModels.gpt4oMini.rawValue
                    
                    do {
                        try viewContext.performAndWait {
                            try viewContext.save()
                        }
                    } catch {
                        // TODO: Handle Errors
                        print("Error saving viewContext in AssistantInformationView... \(error)")
                    }
                }) {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Free Model")
                                .font(.custom(Constants.FontName.heavy, size: 14.0))
                            
                            Text("GPT-4 Mini")
                                .font(.custom(Constants.FontName.bodyOblique, size: 10.0))
                        }
                        Spacer()
                    }
                }
                .padding(8)
                .foregroundStyle(colorScheme == .dark ? (selectedModel == .gpt4oMini ? Colors.elementBackgroundColor : Colors.text) : (selectedModel == .gpt4oMini ? Colors.elementTextColor : Colors.text))
                .background(
                    ZStack {
                        if selectedModel == .gpt4oMini {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                .matchedGeometryEffect(id: "gptModelSelection", in: namespace)
                        }
                    }
                )
                
                // Paid Model Button
                Button(action: {
                    // Ensure premium, otherwise show UltraView and return
                    guard premiumUpdater.isPremium else {
                        self.isShowingUltraView = true
                        return
                    }
                    
                    // Set selectedModel to GPT4
                    withAnimation {
                        self.selectedModel = .gpt4o
                    }
                    
                    // Set currentChatModel in GPTModelHelper to gpt4o
                    GPTModelHelper.currentChatModel = .gpt4o
                    
                    // Set modelName in CoreData
                    self.conversation.modelID = GPTModels.gpt4o.rawValue
                    
                    do {
                        try viewContext.performAndWait {
                            try viewContext.save()
                        }
                    } catch {
                        // TODO: Handle Errors
                        print("Error saving viewContext in AssistantInformationView... \(error)")
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(Image(systemName: "sparkles"))
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Pro Model")
                                    .font(.custom(Constants.FontName.heavy, size: 14.0))
                                
                                if !premiumUpdater.isPremium {
                                    Text(Image(systemName: "lock"))
                                        .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                                }
                            }
                            
                            Text("Pro GPT-4o + Vision")
                                .font(.custom(Constants.FontName.bodyOblique, size: 10.0))
                            
                        }
                        Spacer()
                    }
                }
                .padding(8)
                .foregroundStyle(colorScheme == .dark ? (selectedModel == .gpt4o ? Colors.elementBackgroundColor : Colors.text) : (selectedModel == .gpt4o ? Colors.elementTextColor : Colors.text))
                .background(
                    ZStack {
                        if selectedModel == .gpt4o {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                .matchedGeometryEffect(id: "gptModelSelection", in: namespace)
                        }
                    }
                )
            }
            .padding(4)
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
    }
    
    var modelSettingsToggles: some View {
        VStack(spacing: 16.0) {
            Toggle(isOn: isToggledEnableGoogleSearchUniversal) {
                Text("Enable Web Search")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Text("AI uses Google to find and analyze resources.")
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
            .tint(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
            .padding([.leading, .trailing])
            
            Divider()
            
            Toggle(isOn: $isToggledEnableTextFormatting) {
                Text("Text Formatting")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                
                Text("**Bold**, *italic*, etc")
                    .font(.custom(Constants.FontName.body, size: 12.0))
            }
            .tint(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
            .padding([.leading, .trailing])
        }
        .padding([.top, .bottom])
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .onChange(of: isToggledEnableTextFormatting) { newValue in
            // Set conversation textFormattingDisabled to the opposite of newValue and save
            do {
                try viewContext.performAndWait {
                    conversation.textFormattingDisabled = !newValue
                    
                    try viewContext.save()
                }
            } catch {
                // TODO: Handle Errors
                print("Error saving viewContext in AssistantInformationView... \(error)")
            }
        }
    }
    
}

//#Preview {
//    
//    let fetchRequest = Conversation.fetchRequest()
//    
//    var conversation: Conversation?
//    CDClient.mainManagedObjectContext.performAndWait {
//        conversation = try? CDClient.mainManagedObjectContext.fetch(fetchRequest).last
//    }
//    
//    if let conversation = conversation {
//        return NavigationStack {
//            ZStack {
//                InformationView(
//                    isPresented: .constant(true),
//                    conversation: conversation)
//            }
//            .padding()
//            .background(Colors.background)
////            .popover(isPresented: .constant(true)) {
////                InformationView(
////                    isPresented: .constant(true),
////                    conversation: .constant(conversation))
////                .background(Colors.background)
////            }
//        }
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//        .environmentObject(PremiumUpdater())
//        .environmentObject(ProductUpdater())
//    } else {
//        return ZStack {
//            Text("No Conversations Found...")
//        }
//    }
//    
//}
//
