//
//  PersistentChatGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import CoreData
import Foundation

class PersistentChatGenerator: ObservableObject {
    
    @Published var streamingChat: String?
    
    @Published var isLoading: Bool = false
    @Published var isGenerating: Bool = false
    @Published var isCancelled: Bool = false
    
//    let maxChatCount = 2
    let maxCharacterLengthFree = 10000
    let maxCharacterLengthPaid = 100000
    
    let maxWebResultsFree = 3
    let maxWebResultsPaid = 5
    
    let maxWebResultCharacterLengthFree = 3500
    let maxWebResultCharacterLengthPaid = 6500
    
    private let defaultAttachmentBehaviorAddition = "You are in an app that allows you to see attachments. How exciting! You will be given a transcription of an attachment or sent an image directly. If you cannot read either, ask the user to try attaching it again."
    
    private let maxFreeCharacters: Int = Constants.Additional.freeResponseCharacterLimit
    
    private var total_updates = 0
    
    private var chatGenerator: ChatGenerator?
    
    private var updateChatUpdateCooldown: Int {
        Int.random(in: 4...7)
    }
    
    func cancel() async throws {
        await MainActor.run {
            isCancelled = true
        }
        try await chatGenerator?.cancel()
    }
    
    func streamChat(authToken: String, isPremium: Bool, model: GPTModels, additionalBehavior: String?, conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        // Defer setting isLoading and isGenerating to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isGenerating = false
            }
        }
        
        // Set isLoading to true and streamingChat to nil
        await MainActor.run {
            isCancelled = false
            isLoading = true
            streamingChat = nil
        }
        
        // Get persistent attachment
        let fetchRequest = PersistentAttachment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)]
        fetchRequest.fetchLimit = 1
        
        let persistentAttachment: PersistentAttachment?
        do {
            persistentAttachment = try await managedContext.perform {
                try managedContext.fetch(fetchRequest)[safe: 0]
            }
        } catch {
            // TODO: Handle Errors
            print("Error fetching persistent attachments in ConversationToolbar... \(error)")
            persistentAttachment = nil
        }
        
        // Get behavior with Conversation behavior and keep in mind
        let behavior: String? = try await {
            var behaviorString = try await getBehaviorString(
                conversation: conversation,
                persistentAttachment: persistentAttachment,
                in: managedContext)
            
            if let additionalBehavior = additionalBehavior {
                if behaviorString == nil {
                    behaviorString = additionalBehavior
                } else {
                    behaviorString! += "\n\n\(additionalBehavior)"
                }
            }
            
            return behaviorString
        }()
        
        // Get messages from ConversationToOAIChatCompletionRequestMessagesAdapter for conversation chats and keeping in mind chats
        var messages: [OAIChatCompletionRequestMessage] = []
        if let behavior = behavior {
            messages.append(OAIChatCompletionRequestMessage(role: .system, content: [
                .text(OAIChatCompletionRequestMessageContentText(text: behavior))
            ]))
        }
        messages.append(contentsOf: try await ConversationToOAIChatCompletionRequestMessagsAdapter.adapt(
            conversation: conversation,
            in: managedContext,
            maxCharacterLimit: isPremium ? maxCharacterLengthPaid : maxCharacterLengthFree,
            maxWebResults: isPremium ? maxWebResultsPaid : maxWebResultsFree,
            maxWebResultCharacterLimit: isPremium ? maxWebResultCharacterLengthPaid : maxWebResultCharacterLengthFree))
        messages.append(contentsOf: try await ConversationToOAIChatCompletionRequestMessagsAdapter.adapt(
            chats: try ConversationCDHelper.getKeepingInMind(conversation: conversation, in: managedContext), // TODO: Should this be surrouned in a do catch to catch the error?,
            in: managedContext,
            maxCharacterLimit: isPremium ? maxCharacterLengthPaid : maxCharacterLengthFree,
            maxWebResults: isPremium ? maxWebResultsPaid : maxWebResultsFree,
            maxWebResultCharacterLimit: isPremium ? maxWebResultCharacterLengthPaid : maxWebResultCharacterLengthFree))
        
        // Insert action collection chat at top of messages
        if let actionCollection = conversation.actionCollection {
            var messageString = ""
            
            if let title = actionCollection.title {
                messageString += title + "\n"
            }
            
            if let displayText = actionCollection.displayText {
                messageString += displayText + "\n\n"
            }
            
            if !messageString.isEmpty {
                let message = OAIChatCompletionRequestMessage(
                    role: .user,
                    content: [
                        .text(OAIChatCompletionRequestMessageContentText(text: messageString))
                    ])
                messages.insert(message, at: 0)
            }
        }
        
        // Insert attachment chat at top of messages
        if let persistentAttachment = persistentAttachment {
            // Create attachmentMessageContent
            var attachmentMessageContent: OAIChatCompletionRequestMessageContentType?
            
            // Set attachmentMessageContent to attachment content
            if let attachmentTypeString = persistentAttachment.attachmentType,
               let attachmentType = AttachmentType(rawValue: attachmentTypeString) {
                switch attachmentType {
                case .flashcards:
                    // Set "Flash Cards " and attachment with cached text as attachmentMessageContent
                    if let cachedText = persistentAttachment.cachedText {
                        attachmentMessageContent = .text(OAIChatCompletionRequestMessageContentText(text: defaultAttachmentBehaviorAddition + "\n\nFlash Cards" + "\nBEGIN_ATTACHMENT\n" + cachedText + "\nEND_OF_ATTACHMENT\n"))
                    }
                case .image:
                    // Set to image
                    if let documentsFilepath = persistentAttachment.documentsFilePath,
                       let attachmentImage = try DocumentSaver.getImage(from: documentsFilepath),
                       let attachmentImageData = attachmentImage.jpegData(compressionQuality: 0.8) { // TODO: This error should maybe be caught here..
                        let imageDataString = "data:image/jpeg;base64,\(attachmentImageData.base64EncodedString())"
                        attachmentMessageContent = .imageURL(OAIChatCompletionRequestMessageContentImageURL(
                            imageURL: OAIChatCompletionRequestMessageContentImageURL.ImageURL(
                                url: imageDataString,
                                detail: .auto)))
                    }
                case .pdfOrText:
                    // Set "PDF or Text File " and attachment with cached text as attachmentMessageContent
                    if let cachedText = persistentAttachment.cachedText {
                        attachmentMessageContent = .text(OAIChatCompletionRequestMessageContentText(text: defaultAttachmentBehaviorAddition + "\n\nPDF or Text File" + "\nBEGIN_ATTACHMENT\n" + cachedText + "\nEND_OF_ATTACHMENT\n"))
                    }
                case .voice:
                    // Set "Transcribed Voice " and attachment with cached text as attachmentMessageContent
                    if let cachedText = persistentAttachment.cachedText {
                        attachmentMessageContent = .text(OAIChatCompletionRequestMessageContentText(text: defaultAttachmentBehaviorAddition + "\n\nTranscribed Voice" + "\nBEGIN_ATTACHMENT\n" + cachedText + "\nEND_OF_ATTACHMENT\n"))
                    }
                case .webUrl:
                    // Set "Webpage File " and attachment with cached text as attachmentMessageContent
                    if let cachedText = persistentAttachment.cachedText {
                        attachmentMessageContent = .text(OAIChatCompletionRequestMessageContentText(text: defaultAttachmentBehaviorAddition + "\n\nWebpage File" + "\nBEGIN_ATTACHMENT\n" + cachedText + "\nEND_OF_ATTACHMENT\n"))
                    }
                }
            }
            
            // Create message and insert in messages
            if let attachmentMessageContent = attachmentMessageContent {
                let message = OAIChatCompletionRequestMessage(
                    role: .user,
                    content: [
                        attachmentMessageContent
                    ])
                messages.insert(message, at: 0)
            }
        }
        
        // Construct request
        let getChatRequest = GetChatRequest(
            authToken: authToken,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: !isPremium && model.isPremium ? GPTModels.gpt4oMini.rawValue : model.rawValue, // TODO: This logic should be contained somewhere else so that it is able to be used in other places where GPT model is required
                stream: true,
                messages: messages))
        
        // Reset instance stream variables
        await MainActor.run {
            streamingChat = nil
            total_updates = 0
        }
        
        // Setup stream variables
        var firstMessage = true
        var reachedMaxFreeCharacters = false
        var fullOutputString = ""
        
        // Do stream
        chatGenerator = ChatGenerator()
        do {
            try await chatGenerator?.streamChat(
                getChatRequest: getChatRequest,
                stream: { getChatResponse in
                    if firstMessage {
                        // Do light haptic
                        HapticHelper.doSuccessHaptic()
                        
                        // Set isLoading to false and isGenerating to true
                        await MainActor.run {
                            self.isLoading = false
                            self.isGenerating = true
                        }
                        
                        firstMessage = false
                    }
                    
                    // Ensure get outputString, otherwise return
                    guard let outputString = getChatResponse.body.oaiResponse.choices[safe: 0]?.delta.content else {
                        return
                    }
                    
                    // If user is not premium and outputString is longer than maxFreeCharacters set reachedMaxFreeCharacters to true and return
                    if !isPremium && outputString.count > maxFreeCharacters {
                        reachedMaxFreeCharacters = true
                        return
                    }
                    
                    // Add outputString to fullOutputString
                    fullOutputString += outputString
                    
                    // Update total_updates and chat if cooldown is reached
                    await MainActor.run {
                        total_updates += 1
                    }
                    
                    // If cooldown is reached update streamingChat
                    if total_updates % updateChatUpdateCooldown == 0 {
                        await MainActor.run { [fullOutputString] in
                            self.streamingChat = fullOutputString
                        }
                    }
                    
                    // TODO: If user is not premium limit the response and add the upgrade promo chat
                })
        } catch {
            // TODO: Handle Errors
            print("Error streaming chat in PersistentChatGenerator, though this may be normal... \(error)")
        }
        
        // Update streamingChat with fullOutputString since generation has finished
        await MainActor.run { [fullOutputString] in
            self.streamingChat = fullOutputString
        }
        
        // Ensure first message has been generated, otherwise return before saving context
        guard !firstMessage else {
            // TODO: Handle errors
            throw ChatGeneratorError.nothingFromServer
        }
        
        try await MainActor.run { [fullOutputString, reachedMaxFreeCharacters] in
            let aiChatDate = Date().advanced(by: 0.3)
            
            // Create aiChat
            let aiChat = Chat(context: managedContext)
            
            aiChat.sender = Sender.ai.rawValue
            aiChat.text = fullOutputString
            aiChat.date = aiChatDate
            aiChat.conversation = conversation
            
            // Add additional text if reachedMaxFreeCharacters
            if reachedMaxFreeCharacters {
                aiChat.text? += Constants.lengthFinishReasonAdditionalText
            }
            
            // Update conversation latestChatText to first few characters of fullOutputString
            conversation.latestChatText = String(fullOutputString.prefix(100))
            conversation.latestChatDate = aiChatDate
            
//            streamingChat = nil
            self.isGenerating = false
            
            try managedContext.save()
        }
    }
    
    /**
    Creates behavior like..
     - Conversation behavior
     - If text formatting is not disabled use markdown text formatting string
     - Pronouns if no attachment
     - Keep in mind Chats' text
     - Attachment or action collection summary
     If the behavior is empty will return nil
     */
    private func getBehaviorString(conversation: Conversation, persistentAttachment: PersistentAttachment?, in managedContext: NSManagedObjectContext) async throws -> String? {
        // Build behavior with conversation behavior, formatting unless text formatting disabled, gender, and keep in mind
        
        // Create behavior from conversation behavior
        var behavior = conversation.behavior ?? ""
        
        // Append text formatting capability to behavior if text formatting is not disabled TODO: Is this a good way or place to do this?
        if !conversation.textFormattingDisabled { // Checking if disabled rather than enabled because CoreData defaults to false and I want it to be enabled by default without having to modify anything
            if !behavior.isEmpty {
                behavior += ", "
            }
            behavior += "you may use markdown text formatting"//text bound with one * is italic, ** is bold, no other automatic formatting"
        }
        
        // Pronouns if no attachment TODO: Make the Assistants Pronouns and Prompt contained better, like maybe in a separate entity associated with the Conversation that just copies the important stuff off of Assistants
        if persistentAttachment == nil {
            if let pronouns = conversation.assistant?.pronouns {
                // If behavior is not empty append a comma separator
                if !behavior.isEmpty {
                    behavior += ", "
                }
                
                // Append gender string
                behavior += "pronouns are "
                behavior += pronouns
            }
        }
        
        // Return nil if behavior is empty
        if behavior.isEmpty {
            return nil
        }
        
        // Return behavior
        return behavior
    }
    
}
