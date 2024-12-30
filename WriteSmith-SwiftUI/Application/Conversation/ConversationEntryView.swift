//
//  ConversationEntryView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/1/24.
//

import PhotosUI
import SwiftUI

struct ConversationEntryView: View {
    
    var conversation: Conversation
    var chats: FetchedResults<Chat>
    @Binding var doGenerateBlankRemoveFirstChatIfInConversation: Bool
    @Binding var isShowingConversationSuggestions: Bool
    @Binding var isShowingUltraView: Bool
    @Binding var isSuggestionsViewActive: Bool
    @ObservedObject var conversationChatGenerator: ConversationChatGenerator
    let onOpenCall: () -> Void
    
    @Environment(\.requestReview) private var requestReview
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    
    @State private var isDisplayingPDFFileBrowser: Bool = false

    @State private var isShowingInterstitial: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                // Suggestions
                DefaultOrConversationSuggestionsView(
                    conversation: conversation,
                    isActive: $isSuggestionsViewActive,
                    isShowingConversationSuggestions: $isShowingConversationSuggestions,
                    chats: chats,
                    onSelect: { text, image, imageURL in
                        submitText(text: text, images: image == nil ? nil : [image!], imageURLs: imageURL == nil ? nil : [imageURL!])
                    }
                )
                
                // EntryView for image and text entry
                VStack {
                    HStack(alignment: .bottom) {
                        EntryView(
                            noUserChatsSent: chats.filter({$0.sender == Sender.user.rawValue}).isEmpty,
                            maxHeight: 350.0,
                            conversationChatGenerator: conversationChatGenerator,
                            onOpenAttachFile: {
                                isDisplayingPDFFileBrowser.toggle()
                            },
                            onOpenCall: onOpenCall,
                            onSubmit: { text, image, imageURL in
                                submitText(text: text, images: image == nil ? nil : [image!], imageURLs: imageURL == nil ? nil : [imageURL!])
                            })
//                            onSubmit: { text, images, imageURLs in
//                                submitText(text: text, images: images, imageURLs: imageURLs)
//                            })
                        .onChange(of: conversationChatGenerator.isLoading, perform: { value in
                            //                            // Set face idle animation to thinking if isLoading
                            //                            if value {
                            //                                faceAnimationUpdater.setFaceIdleAnimationToThinking()
                            //                            }
                        })
                        .onChange(of: conversationChatGenerator.isGenerating, perform: { value in
                            //                            // Set face idle animation to writing if isGenerating
                            //                            if value {
                            //                                faceAnimationUpdater.setFaceIdleAnimationToWriting()
                            //                            }
                        })
                    }
                    .padding(.vertical, 8)
                    
                    // Free Trial Promo Button
                    if !premiumUpdater.isPremium {
                        KeyboardDismissingButton(action: {
                            // Do light haptic
                            HapticHelper.doLightHaptic()
                            
                            // Show Ultra View
                            isShowingUltraView = true
                        }) {
                            ZStack {
                                HStack {
                                    Spacer()
                                    
                                    VStack(spacing: -2.0) {
                                        if let introductaryOffer = productUpdater.weeklyProduct?.subscription?.introductoryOffer {
                                            Text("NEW - Send Images\(introductaryOffer.paymentMode == .freeTrial ? "!" : "")")
                                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                                                .foregroundStyle(Colors.elementBackgroundColor)
                                            
                                            if introductaryOffer.paymentMode == .freeTrial {
                                                Text("Tap to Get 7 Days Free...")
                                                    .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                                    .foregroundStyle(Colors.elementBackgroundColor)
                                            } else {
                                                Text("Get access for \(introductaryOffer.price == 0.99 ? "just 99¢" : String(format: "%d%% off", Int(NSDecimalNumber(decimal: (1 - introductaryOffer.price / productUpdater.weeklyProduct!.price) * 100).doubleValue))) today!")
                                                    .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                                    .foregroundStyle(Colors.elementBackgroundColor)
                                            }
                                        } else {
                                            Text("NEW - Send Pictures!")
                                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                                                .foregroundStyle(Colors.elementBackgroundColor)
                                            
                                            Text("Tap to upgrade now...")
                                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                                .foregroundStyle(Colors.elementBackgroundColor)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(8.0)
                        .padding([.leading, .trailing])
                    }
                }
                .background(Colors.foreground)
            }
            .background(
                VStack(spacing: 0.0) {
                    if !premiumUpdater.isPremium {
                        Spacer(minLength: 14.0)
                    }
                    
                    LinearGradient(colors: [Colors.background, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50.0)
                    Colors.background
                }
                    .onTapGesture {
                        // Dismiss keyboard when background is tapped
                        KeyboardDismisser.dismiss()
                    }
            )
        }
        .background(
            InterstitialView(interstitialID: Keys.Ads.Interstitial.chatView, disabled: $premiumUpdater.isPremium, isPresented: $isShowingInterstitial))
        .fileImporter(
            isPresented: $isDisplayingPDFFileBrowser,
            allowedContentTypes: [.pdf, .text],
            onCompletion: { result in
                // Get resultUrl for the file's url from result
                let resultUrl: URL
                do {
                    resultUrl = try result.get()
                } catch {
                    // TODO: Handle Errors
                    print("Error getting resultUrl from attached pdf or text file in ConversationEntryView... \(error)")
                    return
                }
                
                // Save to documents directory
                let resultDocumentsFilepath: String
                do {
                    resultDocumentsFilepath = try DocumentSaver.saveSecurityScopedFileToDocumentsDirectory(from: resultUrl)
                } catch {
                    // Show error alert and return
                    print("Error saving PDF or text to DocumentSvaer in AttachmentsView... \(error)")
//                    alertShowingErrorAttachingPdf = true
                    return
                }
                
                // Attach file to Conversation
                Task {
                    // Create persistent attachment
                    let persistentAttachment: PersistentAttachment
                    do {
                        persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
                            type: .pdfOrText,
                            documentsFilePath: resultDocumentsFilepath,
                            in: viewContext)
                    } catch {
                        // TODO: Handle Errors
                        print("Error creating PersistentAttachment in AttachmentsView... \(error)")
//                        await MainActor.run {
//                            alertShowingErrorAttaching = true
//                        }
                        return
                    }
                    
                    // Update persistentAttachment with conversation
                    do {
                        try await PersistentAttachmentCDHelper.update(persistentAttachment, conversation: conversation, in: viewContext)
                    } catch {
                        // TODO: Handle Errors
                        print("Error updating persistentAttachment's conversation in ConversationAttachmentsView... \(error)")
//                        await MainActor.run {
//                            alertShowingErrorAttaching = true
//                        }
                    }
                    
                    // Remove Assistant text from behavior TODO: This should definitely be done somewhere else or Assistants should be handled better, like copying over important data to a separate object and then being able to control the Assistant's prompt independently like that, but for the time being it needs to be done for all of the attachments
                    do {
                        try await ConversationCDHelper.removeAssistantTextFromBehavior(
                            for: conversation,
                            in: viewContext)
                    } catch {
                        // TODO: Handle Errors
                        print("Error removing assistant text from behavior in AttachmentsView... \(error)")
                    }
                    
                    // Do generate blank remove first chat if in conversation
                    await MainActor.run {
                        doGenerateBlankRemoveFirstChatIfInConversation = true
                    }
                }
            })
    }
    
    func submitText(text: String, images: [UIImage]?, imageURLs: [String]?) {
        // Do haptic
        HapticHelper.doLightHaptic()
        
        // If conversationChatGenerator is loading, return
        if conversationChatGenerator.isLoading {
            return
        }
        
        // if conversationChatGenerator isGenerating, return
        if conversationChatGenerator.isGenerating {
//            alertShowingUpgradeForFasterChats = true
            return
        }
        
        // Start task to generate chat
        Task {
            // Ensure authToken, otherwise return TODO: Handle errors
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle errors
                print("Error ensureing AuthToken in ChatView... \(error)")
                return
            }
            
            do {
                try await conversationChatGenerator.streamGenerateClassifySaveChat(
                    input: text,
                    images: images,
                    imageURLs: imageURLs,
                    authToken: authToken,
                    isPremium: premiumUpdater.isPremium,
                    model: GPTModelHelper.currentChatModel,
                    to: conversation,
                    in: viewContext)
            } catch {
                // TODO: Handle errors
                print("Error generating chat in ChatView... \(error)")
            }
        }
        
        if premiumUpdater.isPremium || !showInterstitialAtFrequency() {
//            requestReview()
        }
    }
    
    func showInterstitialAtFrequency() -> Bool {
        // Ensure not premium, otherwise return false
        guard !premiumUpdater.isPremium else {
            // TODO: Handle errors if necessary
            return false
        }
        
        // Set isShowingInterstitial to true if generated chats count is more than one and its modulo ad frequency is 0 and return true
        let chatsFetchRequest = Chat.fetchRequest()
        chatsFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K = %@", #keyPath(Chat.conversation), conversation, #keyPath(Chat.sender), Sender.ai.rawValue)
        
        do {
            let generatedChatCount = try viewContext.count(for: chatsFetchRequest)//chats.filter({$0.sender == Sender.ai.rawValue}).count
            if generatedChatCount > 0 && remainingUpdater.remaining ?? 0 > 0 && generatedChatCount % Constants.adFrequency == 0 {
                isShowingInterstitial = true
                
                return true
            }
        } catch {
            // TODO: Handle errors if necessary
            print("Error counting generated chats and therefore showing interstitial in EntryView... \(error)")
        }
        
        // Return false
        return false
    }
    
}

//#Preview {
//    
//    let conversation = try! CDClient.mainManagedObjectContext.fetch(Conversation.fetchRequest())[0]
//    
//    @FetchRequest<Chat>(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: true)],
//        predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation.objectID),
//        animation: .default)
//    var fetchRequest
//    
//    return ConversationEntryView(
//        conversation: conversation,
//        chats: fetchRequest,
//        isShowingConversationSuggestions: .constant(true),
//        isShowingUltraView: .constant(false),
//        isSuggestionsViewActive: .constant(false),
//        conversationChatGenerator: ConversationChatGenerator(),
//        onOpenCall: {
//            
//        })
//    .environmentObject(RemainingUpdater())
//    .environmentObject(PremiumUpdater())
//    .environmentObject(ProductUpdater())
//    
//}
