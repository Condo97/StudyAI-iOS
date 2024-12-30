//
//  ChatBubbleView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import MarkdownUI
import SwiftUI
import AVFAudio

struct ChatBubbleView: View {
    
    var text: String?
    var imageData: Data?
    var imageURL: String?
    var flashCardCollection: FlashCardCollection?
    var sender: Sender
    var isFavorited: Bool
    var isKeptInMind: Bool
    var assistant: Assistant?
    var onApplyFlashCardCollection: (() -> Void)?
    var onDelete: (() -> Void)?
    var onFavorite: (() -> Void)?
    var onKeepInMind: (() -> Void)?
    var onReadAloud: (() -> Void)?
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @State private var isBounced: Bool = false
    @State private var isShowingCopyText: Bool = false
    
    @State private var fullScreenImageViewImage: Image?
    private var isShowingFullScreenImageView: Binding<Bool> {
        Binding(
            get: {
                fullScreenImageViewImage != nil
            },
            set: { value in
                if !value {
                    fullScreenImageViewImage = nil
                }
            })
    }
    
    private let copiedTextAnimationDuration: CGFloat = 0.2
    private let copiedTextAnimationDelay: CGFloat = 0.4
    
    var body: some View {
        BubbleBackgroundView(
            sender: sender,
            assistant: assistant,
            content: {
                ZStack {
                    VStack(alignment: sender == .user ? .trailing : .leading) {
                        // Attachment
                        if let imageData = imageData, let image = UIImage(data: imageData) {
                            // Image
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 280.0)
                                .clipShape(RoundedRectangle(cornerRadius: 12.0))
//                                .padding(8)
                            
//                            // Divider if there is also text
//                            if text != nil {
//                                Divider()
//                                    .background(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
//                                    .opacity(0.2)
//                            }
                        } else if let flashCardCollection = flashCardCollection {
                            // Flash Card Collection
                            FlashCardCollectionMiniContainer(
                                flashCardCollection: flashCardCollection,
                                height: 100.0,
                                fontSize: 14.0)
                            .shadow(radius: 1.0)
                            
                            // Flash Card Buttons
                            HStack {
                                if let onApplyFlashCardCollection = onApplyFlashCardCollection {
                                    Button(action: onApplyFlashCardCollection) {
                                        Text("Apply to Chat")
                                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                                            .underline()
                                    }
                                }
                                
                                Spacer()
                            }
                            
//                            // Divider if there is also text
//                            if text != nil {
//                                Divider()
//                                    .background(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
//                                    .opacity(0.2)
//                            }
                        }
                        
                        // Text
                        if let text = text {
                            HStack {
                                Markdown(text)
                                    .markdownTheme(Theme.basic
                                        .heading1 { configuration in
                                            configuration.label
                                                .markdownTextStyle {
                                                    FontWeight(.bold)
                                                    FontSize(17)
                                                }
                                        }
                                        .heading2 { configuration in
                                            configuration.label
                                                .markdownTextStyle {
                                                    FontWeight(.bold)
                                                    FontSize(14)
                                                }
                                        }
                                        .heading3 { configuration in
                                            configuration.label
                                                .markdownTextStyle {
                                                    FontWeight(.bold)
                                                    FontSize(14)
                                                }
                                        }
                                        .heading4 { configuration in
                                            configuration.label
                                                .markdownTextStyle {
                                                    FontWeight(.bold)
                                                    FontSize(14)
                                                }
                                        }
                                        .heading5 { configuration in
                                            configuration.label
                                                .markdownTextStyle {
                                                    FontWeight(.bold)
                                                    FontSize(14)
                                                }
                                        }
                                        .heading6 { configuration in
                                            configuration.label
                                                .markdownTextStyle {
                                                    FontWeight(.bold)
                                                    FontSize(14)
                                                }
                                        }
                                        .text {
                                            FontSize(14)
                                            FontFamily(.custom(sender == .user ? Constants.FontName.heavy : Constants.FontName.body))
                                            ForegroundColor(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                                        }
                                        .codeBlock { configuration in
                                            configuration.label
                                                .padding(8)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 14.0)
                                                        .fill(Colors.background)
                                                        .frame(maxWidth: .infinity)
                                                }
                                        }
                                        .link {
                                            UnderlineStyle(.single)
                                            ForegroundColor(Colors.elementBackgroundColor)
                                        })
                                
                                //                                        .font(.custom(sender == .user ? Constants.FontName.heavy : Constants.FontName.body, size: 14.0))
                                    .frame(minWidth: 28.0)
                            }
                            .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                        }
                    }
                }
                .padding([.top, .bottom], 14)
                .padding([.leading, .trailing], 14)
                .opacity(isShowingCopyText ? 0.0 : 1.0)
                
                if isShowingCopyText {
                    Text("Copied")
                        .font(.custom(Constants.FontName.black, size: 20.0))
                        .foregroundStyle(sender == .user ? Colors.userChatTextColor : Colors.aiChatTextColor)
                }
            })
        .bounceableOnChange(bounce: $isBounced)
        .contextMenu {
            // Keep in Mind
            if let onKeepInMind = onKeepInMind {
                Button(action: onKeepInMind) {
                    if isKeptInMind {
                        Image(systemName: "pin.fill")
                        
                        Text("Remove Keep in Mind")
                    } else {
                        Image(systemName: "pin")
                        
                        Text("Keep in Mind")
                    }
                }
            }
            
            // Favorite
            if let onFavorite = onFavorite {
                Button(action: onFavorite) {
                    if isFavorited {
                        Image(systemName: "heart.fill")
                        
                        Text("Remove Favorite")
                    } else {
                        Image(systemName: "heart")
                        
                        Text("Favorite")
                    }
                }
            }
            
            Divider()
            
            // Read Aloud
            if let onReadAloud = onReadAloud {
                Button(action: onReadAloud) {
                    Image(systemName: "speaker.wave.3")
                    
                    Text("Read Aloud")
                }
            }
            
            Divider()
            
            // Copy
            if let chatText = text {
                Button(action: { PasteboardHelper.copy(chatText, showFooterIfNotPremium: true, isPremium: premiumUpdater.isPremium) }) {
                    Image(systemName: "doc.on.doc")
                    
                    Text("Copy")
                }
            }
            // TODO: Add share copy images
            
            // Share
            if let chatText = text {
                ShareLink(item: chatText) {
                    Image(systemName: "arrowshape.turn.up.right")
                    
                    Text("Share")
                }
            }
            // TODO: Add share copy images
            
            // Delete
            if let onDelete = onDelete {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                    
                    Text("Delete")
                }
            }
        }
        .onTapGesture {
            onTapEnded()
        }
//        .simultaneousGesture(TapGesture()
//            .onEnded(onTapEnded)
//        )
        .fullScreenCover(isPresented: isShowingFullScreenImageView) {
            FullScreenImageView(
                isPresented: isShowingFullScreenImageView,
                image: $fullScreenImageViewImage)
        }
    }
    
    func showCopiedText() async throws {
        // Ensure not isShowingCopyText, otherwise return
        guard !isShowingCopyText else {
            return
        }
        
        // Defer setting isShowingCopyText to false to ensure it is always executed on completion
        defer {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: copiedTextAnimationDuration)) {
                    isShowingCopyText = false
                }
            }
        }
        
        // Set isShowingCopyText to true
        await MainActor.run {
            withAnimation(.easeInOut(duration: copiedTextAnimationDuration)) {
                isShowingCopyText = true
            }
        }
        
        // Wait for copiedTextAnimationDelay
        try await Task.sleep(nanoseconds: UInt64(copiedTextAnimationDelay * CGFloat(1_000_000_000)))
    }
    
    func onTapEnded() {
        // TODO: I feel like this code or maybe this and even the drag code should be abstracted into other structs that use eachother
        
//        // Ensure not isDragged, otherwise return
//        guard !isDragged else {
//            return
//        }
        
        // Set isBounced to true to do bounce
        isBounced = true
        
        // Do light haptic
        HapticHelper.doLightHaptic()
        
        // Copy
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
//            UIPasteboard.general.image = image
            // Set fullScreenImageViewImage to image with uiImage
            fullScreenImageViewImage = Image(uiImage: uiImage)
        } else if let chatText = text {
            // Copy text to pasteboard
            PasteboardHelper.copy(chatText)
            
            // Show "Copied" text
            Task {
                do {
                    try await showCopiedText()
                } catch {
                    // TODO: Handle errors
                    print("Error showing copied text in BubbleBackgroundView... \(error)")
                }
            }
        }
    }
    
}

#Preview {
    
    let fetchRequest = Chat.fetchRequest()
    let chat = try! CDClient.mainManagedObjectContext.performAndWait {
        return try CDClient.mainManagedObjectContext.fetch(fetchRequest)[0]
    }
    
    return ChatBubbleView(
        text: "Test Text",
        imageData: nil,
        imageURL: nil,
        sender: .user,
        isFavorited: false,
        isKeptInMind: false,
        assistant: chat.conversation!.assistant,
        onApplyFlashCardCollection: {
            
        },
        onDelete: {
            
        },
        onFavorite: {
            
        },
        onKeepInMind: {
            
        },
        onReadAloud: {
            
        })
    
}
