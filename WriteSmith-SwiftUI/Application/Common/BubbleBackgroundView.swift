//
//  BubbleBackgroundView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct BubbleBackgroundView<Content>: View where Content: View {
    
    @State var sender: Sender
    @State var assistant: Assistant?
    @ViewBuilder var content: () -> Content
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    private let defaultAIChatSenderImage: Image = Image(FaceStyles.man.staticImageName)
    private let userChatSenderImage: Image = Image(systemName: "pencil")
    
    
    var body: some View {
        ZStack {
            HStack {
                if sender == .user {
                    Spacer(minLength: 0.0)
                }
                
                ZStack {
                    switch sender {
                    case .ai:
                        HStack(spacing: 0.0) {
                            senderImageDisplay
                            
                            bubble
                            
                            //                        Spacer()
                        }
                        //                        .fixedSize(horizontal: false, vertical: true)
                    case .user:
                        HStack(spacing: 0.0) {
                            //                            Spacer()
                            
                            bubble
                            
                            senderImageDisplay
                        }
                        //                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                if sender == .ai {
                    Spacer(minLength: 0.0)
                }
                
            }
            
            //            .offset(x: dragOffset)
            //            .scaleEffect(1 - pow(Double(dragOffset) / 40, 2) / 100)
            //            .opacity(1 - pow(Double(dragOffset) / 40, 2) / 100)
        }
        
    }
    
    var senderImageDisplay: some View {
        ZStack {
            VStack {
                Spacer()
                
                ZStack {
                    if sender == .user {
                        // Show user chat sender image
                        userChatSenderImage
                            .resizable()
                    } else {
                        // Show Assistant static face image, uiImage, emoji, current assistant static face image, or default AI chat sender image
                        if let staticFaceImageName = assistant?.faceStyle?.staticImageName {
                            // Static Face Image Name if the Assistant has a faceStyle
                            Image(staticFaceImageName)
                                .resizable()
                        } else if let assistantUIImage = assistant?.uiImage {
                            // UIImage if the Assistant has a uiImage
                            Image(uiImage: assistantUIImage)
                                .resizable()
                        } else if let assistantEmoji = assistant?.emoji {
                            // Emoji with background if the Assistant has an emoji
                            ZStack {
                                Color.clear
                                    .overlay {
                                        Text(assistantEmoji)
                                            .font(.custom(Constants.FontName.body, size: 14.0))
                                            .minimumScaleFactor(0.5)
                                            .padding(2)
                                    }
                            }
                        } else if let currentAssistantStaticFaceImageName = try? CurrentAssistantPersistence.getAssistant(in: viewContext)?.faceStyle?.staticImageName {
                            // Current assistant static face image if there is a current assistant with a face style
                            Image(currentAssistantStaticFaceImageName)
                                .resizable()
                        } else {
                            // Default to defaultAIChatSenderImage
                            defaultAIChatSenderImage
                                .resizable()
                        }
                    }
                }
                .aspectRatio(contentMode: .fit)
                .padding(sender == .user ? 8 : 0) // TODO: This is because the User one uses a symbol.. is this okay to do here?
                .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                .background(sender == .user ? Colors.userChatBubbleColor : Colors.aiChatBubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                .frame(width: 32.0, height: 32.0)
            }
        }
    }
    
    var bubble: some View {
        ZStack {
            ZStack {
                content()
            }
            .padding(sender == .user ? .trailing : .leading, 8.0)
            .frame(minWidth: 40.0)
            .background(
                BubbleImageMaker.makeBubbleImage(userSent: sender == .user)
                    .foregroundStyle(sender == .user ? Colors.userChatBubbleColor : Colors.aiChatBubbleColor)
            )
        }
    }
    
}

//@available(iOS 17.0, *)
//#Preview(traits: .sizeThatFitsLayout) {
//    
//    // Insert a Chat
//    let chat = Chat(context: CDClient.mainManagedObjectContext)
//    chat.text = "asdfadsf"
//    chat.date = Date()
//    
//    CDClient.mainManagedObjectContext.performAndWait {
//        try? CDClient.mainManagedObjectContext.save()
//    }
//    
//    // Get Assistant
//    let assistantFetchRequest = Assistant.fetchRequest()
//    
//    var assistant: Assistant?
//    CDClient.mainManagedObjectContext.performAndWait {
//        assistant = try? CDClient.mainManagedObjectContext.fetch(assistantFetchRequest)[safe: 89]
//    }
//    
//    return BubbleBackgroundView(
//        sender: .ai,
//        assistant: assistant,
//        content: {
//            Text("Test")
//        })
//    .background(Color(uiColor: .gray))
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//}
