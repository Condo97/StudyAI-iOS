//
//  ConversationViewContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/27/24.
//

import Foundation
import SwiftUI

struct ConversationViewContainer: View {
    
    var conversation: Conversation
    var initialChatGenerationText: String?
    var initialChatGenerationImage: UIImage?
    var initialChatGenerationImageURL: String?
    var onCreateConversation: (Assistant?) -> Void
    
    private let defaultAdditionalSystemMessage: String = "You are an intelligent and efficient AI tutor for StudyAI. Provide concise and direct answers to users' questions. When solving problems or explaining concepts, present clear, step-by-step solutions. Ensure that each step is logical and contributes to a thorough understanding, while keeping explanations succinct and to the point."
    private let attachmentSummaryAdditionalSystemMessage: String = "You are an intelligent and efficient AI tutor for StudyAI. Provide concise and direct answers to users' questions. When solving problems or explaining concepts, present clear, step-by-step solutions. Ensure that each step is logical and contributes to a thorough understanding, while keeping explanations succinct and to the point."
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var constantsUpdater: ConstantsUpdater
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @StateObject private var conversationChatGenerator: ConversationChatGenerator = ConversationChatGenerator()
    @StateObject private var queuedAudioPlayer: QueuedAudioPlayer = QueuedAudioPlayer()
    
    @State private var doGenerateBlankRemoveFirstChatIfInConversation: Bool = false // Used for when doing attachment in same conversation, not new conversation // Set to true to remove first chat and generate a chat for cases like adding an attachment
    
    @State private var isLoadingSpeech: Bool = false
    
    @State private var isShowingLiveSpeechView = false
    
    var body: some View {
//        let _ = Self._printChanges()
        ConversationView(
            conversation: conversation,
            persistentAttachments: FetchRequest(
                sortDescriptors: [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)],
                predicate: NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation)),
            doGenerateBlankRemoveFirstChatIfInConversation: $doGenerateBlankRemoveFirstChatIfInConversation,
            conversationChatGenerator: conversationChatGenerator,
            onCreateConversation: onCreateConversation,
            onOpenCall: {
                isShowingLiveSpeechView = true
            },
            onSpeakText: { text in
                Task {
                    // Defer setting isLoadingSpeech to false
                    defer {
                        DispatchQueue.main.async {
                            self.isLoadingSpeech = false
                        }
                    }
                    
                    await MainActor.run {
                        isLoadingSpeech = true
                    }
                    
                    // Ensure authToken
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle Errors
                        print("Error ensuring authToken in LiveSpeechContainer... \(error)")
                        return
                    }
                    
                    let speech: Data
                    do {
                        speech = try await SpeechGenerator.generateSpeech(authToken: authToken, input: text, speed: constantsUpdater.liveSpeechSpeed, voice: constantsUpdater.liveSpeechVoice)
                    } catch {
                        // TODO: Handle Errors
                        print("Error getting speech in ConversationChatsView... \(error)")
                        return
                    }
                    
                    queuedAudioPlayer.queue(data: speech)
                }
            })
        .overlay {
            if isLoadingSpeech {
                ZStack {
                    Colors.foreground
                        .opacity(0.4)
                    ProgressView()
                }
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $isShowingLiveSpeechView) {
            if #available(iOS 17, *) {
                LiveSpeechContainer(
                    isPresented: $isShowingLiveSpeechView,
                    conversation: conversation,
                    persistentAttachments: FetchRequest(
                        sortDescriptors: [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)],
                        predicate: NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation)))
                .padding()
                .background(Colors.background)
            } else {
                // Fallback on earlier versions
                Text("Please Upgrade to iOS 17")
            }
        }
        .alert("Error Creating Flash Cards", isPresented: $conversationChatGenerator.alertShowingErrorGeneratingFlashCardCollection, actions: {
            Button("Close") {
                
            }
        }) {
            Text("There was an issue creating your flash cards. Please try again.")
        }
        .alert("Chat Not Saved", isPresented: $conversationChatGenerator.alertShowingUserChatNotSaved, actions: {
            Button("Close") {
                
            }
        }) {
            Text("Your chat could not be saved. Please try again.")
        }
        .task {
            do {
                // If fresh conversation and no attachment add initial chat, if attachment get the attachment text
                if try await isEmptyConversation() {
                    let persistentAttachmentFetchRequest = PersistentAttachment.fetchRequest()
                    persistentAttachmentFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation)
                    persistentAttachmentFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)]
                    let persistentAttachments = try await viewContext.perform {
                        try viewContext.fetch(persistentAttachmentFetchRequest)
                    }
                    
                    if persistentAttachments.count == 0 {
                        // TODO: Initial chats should be able to be applied even if there is an attachment
                        
                        // If initial chat generate with that
                        if initialChatGenerationText != nil || initialChatGenerationImage != nil || initialChatGenerationImageURL != nil {
                            let authToken = try await AuthHelper.ensure()
                            
                            try await conversationChatGenerator.streamGenerateClassifySaveChat(
                                input: initialChatGenerationText,
                                images: initialChatGenerationImage == nil ? nil : [initialChatGenerationImage!],
                                imageURLs: initialChatGenerationImageURL == nil ? nil : [initialChatGenerationImageURL!],
                                additionalBehavior: defaultAdditionalSystemMessage,
                                authToken: authToken,
                                isPremium: premiumUpdater.isPremium,
                                model: GPTModelHelper.currentChatModel,
                                to: conversation,
                                in: viewContext)
                        } else {
                            // Add initial chat if no chats
                            let newChatText: String = conversation.assistant?.initialMessage ?? FirstChats.getRandomFirstChat()
                            do {
                                try await ChatCDHelper.appendChat(
                                    sender: .ai,
                                    text: newChatText,
                                    to: conversation,
                                    in: CDClient.mainManagedObjectContext)
                            } catch {
                                // TODO: Handle Errors
                                print("Error appending chat to conversation in ConversationViewContainer... \(error)")
                            }
                        }
                    } else {
                        // Attachments, get attachment text
                        do {
                            let authToken = try await AuthHelper.ensure()
                            
                            try await conversationChatGenerator.streamGenerateClassifySaveChat(
                                authToken: authToken,
                                isPremium: premiumUpdater.isPremium,
                                model: GPTModelHelper.currentChatModel,
                                conversation: conversation,
                                in: viewContext)
                        } catch {
                            // TODO: Handle Errors if Necessary
                            print("Error generating blank removing first chat if in conversation in ConversationAttachmentsView, continuing... \(error)")
                        }
                    }
                }
            } catch {
                // TODO: Handle Errros
                print("Error getting isFreshConversation in ConversationViewContainer... \(error)")
            }
            
        }
        .onChange(of: conversation) { newValue in
            Task {
                // If Conversation has one chat and it is a initial chat (there are no chats)..
                //      If there is an attachment set doGenerateBlankRemoveFirstChatIfInConversation to true.
                //      If there is no attachment add chat
                let chatsFetchRequest = Chat.fetchRequest()
                chatsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), newValue)
                chatsFetchRequest.fetchLimit = 2
                let chats: [Chat]
                do {
                    chats = try await viewContext.perform {
                        try viewContext.fetch(chatsFetchRequest)
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error fetching chats in ConversationViewContainer... \(error)")
                    return
                }
                
                if chats.count <= 1 {
                    // If there is a chat ensure chat is initialChat, otherwise return
                    if let firstChat = chats.first,
                       let firstChatText = firstChat.text {
                        guard firstChatText == newValue.assistant?.initialMessage || FirstChats.firstChats.contains(firstChatText) || FirstChats.firstEverChat == firstChatText else {
                            // First chat is not initial message so return
                            return
                        }
                    }
                    
                    let persistentAttachmentsFetchRequest = PersistentAttachment.fetchRequest()
                    persistentAttachmentsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), newValue)
                    persistentAttachmentsFetchRequest.fetchLimit = 1
                    let persistentAttachments: [PersistentAttachment]
                    do {
                        persistentAttachments = try await viewContext.perform {
                            try viewContext.fetch(persistentAttachmentsFetchRequest)
                        }
                    } catch {
                        // TODO: Handle Errors
                        print("Error fetching persistent attachments in ConversationViewContainer... \(error)")
                        return
                    }
                    
                    if persistentAttachments.count > 0 {
                        // Generate first chat since there is an attachment
                        doGenerateBlankRemoveFirstChatIfInConversation = true
                    } else {
                        // Put a new chat in
                        let newChatText: String = newValue.assistant?.initialMessage ?? FirstChats.getRandomFirstChat()
                        do {
                            try await ChatCDHelper.appendChat(
                                sender: .ai,
                                text: newChatText,
                                to: newValue,
                                in: CDClient.mainManagedObjectContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error appending chat to conversation in ConversationViewContainer... \(error)")
                        }
                    }
                }
            }
        }
        .onChange(of: doGenerateBlankRemoveFirstChatIfInConversation) { newValue in
            if newValue {
                Task {
                    // Generate attachment summary by generating blank and removing first chat if necessary
                    do {
                        // Ensure unwrap authToken
                        let authToken = try await AuthHelper.ensure()
                        
                        // Remove initial chat
                        try await removeInitialChatIfFreshConversation()
                        
                        // Generate attachment summary by generating blank and removing first chat if necessary
                        do {
                            try await conversationChatGenerator.streamChat(
                                authToken: authToken,
                                isPremium: premiumUpdater.isPremium,
                                model: GPTModelHelper.currentChatModel,
                                additionalBehavior: attachmentSummaryAdditionalSystemMessage,
                                conversation: conversation,
                                in: viewContext)
                        } catch {
                            // TODO: Handle Errors if Necessary
                            print("Error generating blank removing first chat if in conversation in ConversationAttachmentsView, continuing... \(error)")
                        }
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error ensuring authToken in ConversationAttachmentsView, continuing... \(error)")
                    }
                    
                    // Set doGenerateBlankRemoveFirstChatIfInConversation to false
                    await MainActor.run {
                        doGenerateBlankRemoveFirstChatIfInConversation = false
                    }
                }
                
            }
        }
    }
        
        func isEmptyConversation() async throws -> Bool {
            // Fetch chats
            let chatFetchRequest = Chat.fetchRequest()
    //        chatFetchRequest.fetchLimit = maxChatCount
            chatFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
            chatFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: true)]
            let chats = try await viewContext.perform {
                return try viewContext.fetch(chatFetchRequest)
            }
            
//            // Remove first chat if it's the only chat and its text is an initial chat
//            if chats.count == 1 && chats[0].sender == Sender.ai.rawValue,
//               let chatText = chats[0].text,
//               FirstChats.firstChats.contains(chatText) {
//                return true
            if chats.count == 0 {
                return true
            }
            
            return false
        }
    
    // True if the conversation contains no chats or a default initial chat, otherwise false
    func removeInitialChatIfFreshConversation() async throws {
        // Fetch chats
        let chatFetchRequest = Chat.fetchRequest()
//        chatFetchRequest.fetchLimit = maxChatCount
        chatFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
        chatFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: true)]
        let chats = try await viewContext.perform {
            return try viewContext.fetch(chatFetchRequest)
        }
        
        // Remove first chat if it's the only chat and its text is an initial chat
        if chats.count == 1 && chats[0].sender == Sender.ai.rawValue,
           let chatText = chats[0].text,
           FirstChats.firstChats.contains(chatText) {
            do {
                try ChatCDHelper.deleteChat(
                    chat: chats[0],
                    in: viewContext)
            } catch {
                // TODO: Handle Errors if Necessary
                print("Error deleting previous initial chat after attaching a file... \(error)")
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
//        let results = try? CDClient.mainManagedObjectContext.fetch(fetchRequest)
//        
//        conversation = results![0]
//    }
//    
//    return ConversationViewContainer(
//        conversation: .constant(conversation),
//        shouldDoInitialChatGeneration: .constant(false),
//        initialChatGenerationText: .constant(nil),
//        initialChatGenerationImage: .constant(nil),
//        initialChatGenerationImageURL: .constant(nil)
//    )
//    
//}
