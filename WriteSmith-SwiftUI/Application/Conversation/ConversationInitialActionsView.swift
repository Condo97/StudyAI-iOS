//
//  ConversationInitialActionsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/1/24.
//

import SwiftUI

struct ConversationInitialActionsView: View {
    
    var conversation: Conversation
//    var conversationChatGenerator: ConversationChatGenerator
    var notFirstLaunchEver: Bool
    @Binding var presentingAction: Action?
    @Binding var isShowingFlashCardCollectionCreator: Bool
    @Binding var doGenerateBlankRemoveFirstChatIfInConversation: Bool
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    var body: some View {
        // Banner Ad
        if !premiumUpdater.isPremium && notFirstLaunchEver {
            BannerView(bannerID: Keys.Ads.Banner.chatView)
                .padding(.bottom, 8)
        }
        
        VStack {
            // Add Content Title and Subtitle
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
            
            // Conversation Attachments
            ConversationAttachmentsView(
                conversation: conversation,
                doGenerateBlankRemoveFirstChatIfInConversation: $doGenerateBlankRemoveFirstChatIfInConversation)
            
            // Study Tools Title
            HStack {
                Text("Study Tools")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                    .foregroundStyle(Colors.textOnBackgroundColor)
                
                Spacer()
            }
            .padding([.leading, .trailing])
            HStack {
//                Text("Transform your notes and lectures into study tools.")
                Text("Learn faster from your notes and lectures.")
                    .font(.custom(Constants.FontName.light, size: 12.0))
                    .foregroundStyle(Colors.textOnBackgroundColor)
                
                Spacer()
            }
            .padding([.leading, .trailing])
            
            HStack {
                // Action Collection Flow Creator
                ActionCollectionFlowCreatorView(conversation: conversation, presentingAction: $presentingAction)
                
                // Create Flashcards
                ConversationInitialActionButton(
                    title: "\(Image(systemName: "rectangle.on.rectangle.angled")) Flash Cards",
//                    subtitle: "Create flash cards and play games.",
                    action: {
                        isShowingFlashCardCollectionCreator = true
                    })
            }
            .padding([.leading, .trailing])
        }
    }
    
}

//#Preview {
//    
//    ConversationInitialActionsView(
//        conversation: try! CDClient.mainManagedObjectContext.fetch(Conversation.fetchRequest())[0],
////        conversationChatGenerator: ConversationChatGenerator(),
//        notFirstLaunchEver: true,
//        presentingAction: .constant(nil),
//        isShowingFlashCardCollectionCreator: .constant(false),
//        doGenerateBlankRemoveFirstChatIfInConversation: .constant(false)
//    )
//    
//}
