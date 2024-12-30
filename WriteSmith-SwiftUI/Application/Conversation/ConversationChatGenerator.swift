//
//  ConversationChatGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/5/24.
//

import CoreData
import Foundation
import UIKit

class ConversationChatGenerator: PersistentChatGenerator {
    
    @Published var webSearchQuery: String?
    @Published var alertShowingErrorGeneratingFlashCardCollection = false
    @Published var alertShowingUserChatNotSaved = false
    @Published var isShowingPromoImageGenerationView = false
    @Published var isDisplayingPromoSendImagesView = false
    @Published var isLoadingFlashCards: Bool = false
    @Published var isLoadingWebSearch: Bool = false
    
    private let defaultAttachmentBehaviorAddition = "You are in an app that allows you to see attachments. How exciting! You will be given a transcription of an attachment or sent an image directly. If you cannot read either, ask the user to try attaching it again."
    private let defaultImageGenerationErrorAIMessage: String = "Please try generating that again."
    private let imageGenerationErrorAIMessages: [String] = [
        "Please try generating that again.",
        "Hmm, I had an issue generating your image. Please try again and double-check your prompt to make sure it's appropriate.",
        "There was an issue generating your image. Please try rephrasing the prompt, and make sure it's appropriate.",
        "There was an issue generating your image. Please try again.",
        "Hm, I couldn't generate that. Can you try something else?"
    ]
    
    private let maxChatsForClassificationAndImageGeneration: Int = 5
    private let promoImageGenerationChatText: String = "Please upgrade to generate **unlimited** images. AI art is created with DALL-E 3, and it's expensive! Thank you 😊"
    private let promoImageSendChatText: String = "Please upgrade to send **unlimited** images and support the developer. Thank you!"
    
    func streamGenerateClassifySaveChat(input: String?, images: [UIImage]?, imageURLs: [String]?, additionalBehavior: String? = nil, authToken: String, isPremium: Bool, model: GPTModels, to conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        // Create User Image URL Chats
        var userImageURLChats: [Chat] = []
        if let imageURLs = imageURLs, !imageURLs.isEmpty {
            userImageURLChats = imageURLs.compactMap { imageURL in
                managedContext.performAndWait {
                    let userImageURLChat = Chat(context: managedContext)
                    userImageURLChat.imageURL = imageURL
                    userImageURLChat.sender = Sender.user.rawValue
                    userImageURLChat.date = Date()
                    userImageURLChat.conversation = conversation
                    return userImageURLChat
                }
            }
        }
        
        // Create User Image Chats
        var userImageChats: [Chat] = []
        if let images = images, !images.isEmpty {
            userImageChats = images.compactMap { image in
                managedContext.performAndWait {
                    let userImageChat = Chat(context: managedContext)
                    userImageChat.imageData = image.jpegData(compressionQuality: 0.8)
                    userImageChat.sender = Sender.user.rawValue
                    userImageChat.date = Date().addingTimeInterval(0.1)
                    userImageChat.conversation = conversation
                    return userImageChat
                }
            }
        }
        
        // Create User Text Chat
        let userTextChat: Chat? = {
            guard let input = input, !input.isEmpty else {
                return nil
            }
            return managedContext.performAndWait {
                let userTextChat = Chat(context: managedContext)
                userTextChat.text = input
                userTextChat.sender = Sender.user.rawValue
                userTextChat.date = Date().addingTimeInterval(0.2)
                userTextChat.conversation = conversation
                return userTextChat
            }
        }()
        
        // Update conversation latestChatText
        if let input = input {
            await managedContext.perform {
                conversation.latestChatText = String(input.prefix(100))
                conversation.latestChatDate = Date()
            }
        } else if (!userImageURLChats.isEmpty || !userImageChats.isEmpty) {
            await managedContext.perform {
                conversation.latestChatText = "[Image]"
                conversation.latestChatDate = Date()
            }
        }
        
        // Save context
        try await managedContext.perform {
            try managedContext.save()
        }
        
        // Handle image send limitations and promo display
        var shouldIncrementImageSendLimiter = false
        let totalImagesCount = userImageChats.count + userImageURLChats.count
        if !isPremium && totalImagesCount > 0 {
            if !ImageSendLimiter.canSendImages(isPremium: isPremium, count: totalImagesCount) {
                await MainActor.run {
                    // Display send images promo view
                    self.isDisplayingPromoSendImagesView = true
                    
                    managedContext.performAndWait {
                        // Send send images promo chat
                        let promoImageSendChat = Chat(context: managedContext)
                        promoImageSendChat.conversation = conversation
                        promoImageSendChat.sender = Sender.ai.rawValue
                        promoImageSendChat.text = promoImageSendChatText
                        promoImageSendChat.date = Date()
                        
                        do {
                            try managedContext.save()
                        } catch {
                            // TODO: Handle Errors
                            print("Error saving managedContext in ConversationChatGenerator")
                        }
                    }
                }
                return
            }
            shouldIncrementImageSendLimiter = true
        }
        
        // Stream generate chat
        try await streamGenerateClassifySaveChat(
            authToken: authToken,
            isPremium: isPremium,
            model: model,
            additionalBehavior: additionalBehavior,
            conversation: conversation,
            in: managedContext)
        
        // Increment image send limiter if necessary
        if shouldIncrementImageSendLimiter {
            ImageSendLimiter.increment(by: totalImagesCount)
        }
    }
    
    func streamGenerateClassifySaveChat(authToken: String, isPremium: Bool, model: GPTModels, additionalBehavior: String? = nil, conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        // Defer setting isLoading and isLoadingWebSearch to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isLoadingWebSearch = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoading = true
        }
        
        // Get Conversation Chats
        let fetchRequest = Chat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: true)]
        let chats = try await managedContext.perform {
            return try managedContext.fetch(fetchRequest)
        }
        
        // Transform chats to role and message tuple array
        let roleAndMessages: [(role: CompletionRole, message: String)] = chats.suffix(maxChatsForClassificationAndImageGeneration).compactMap {
            guard let senderRaw = $0.sender, let sender = Sender(rawValue: senderRaw), let text = $0.text else { return nil }
            return (role: CompletionRole.from(sender: sender), message: text)
        }
        
        // Classify conversation chats
        let chatClassifications: ClassifyChatsSO? = await {
            if let lastChatText = chats.last?.text {
                do {
                    return try await classifyChat(
                        authToken: authToken,
                        prompt: lastChatText)
                } catch {
                    // TODO: Handle Errors
                    print("Error classifying chat in ConversationChatGenerator... \(error)")
                }
            }
            return nil
        }()
        
        if chatClassifications?.wantsFlashCards ?? false {
            // If requests flash cards, generate flash cards
            try await generateFlashCards(
                authToken: authToken,
                conversation: conversation,
                managedContext: managedContext,
                maxCharacterLimit: isPremium ? maxCharacterLengthPaid : maxCharacterLengthFree,
                maxWebResults: isPremium ? maxWebResultsPaid : maxWebResultsFree,
                maxWebResultCharacterLimit: isPremium ? maxWebResultCharacterLengthPaid : maxWebResultCharacterLengthFree)
        } else if chatClassifications?.wantsImageGeneration ?? false {
            // If requests image generation and can generate image
            if !ImageGenerationLimiter.canGenerateImage(isPremium: isPremium) {
                // Show promo image generation view and return
                await MainActor.run {
                    isShowingPromoImageGenerationView = true
                    
                    managedContext.performAndWait {
                        let promoImageGenerationChat = Chat(context: managedContext)
                        promoImageGenerationChat.conversation = conversation
                        promoImageGenerationChat.sender = Sender.ai.rawValue
                        promoImageGenerationChat.text = promoImageGenerationChatText
                        promoImageGenerationChat.date = Date()
                        
                        do {
                            try managedContext.save()
                        } catch {
                            // TODO: Handle Errors
                            print("Error saving managedContext in ConversationChatGenerator")
                        }
                    }
                }
                return
            }
            
            // Get imageData
            let imageData = try await GPTPromptedImageGenerator.generateGPTPromptedImageData(
                authToken: authToken,
                chats: roleAndMessages)
            
            do {
                // Create and save Chat with generated image
                try await managedContext.perform {
                    let aiChat = Chat(context: managedContext)
                    aiChat.sender = Sender.ai.rawValue
                    aiChat.imageData = imageData
                    aiChat.date = Date()
                    aiChat.conversation = conversation
                    try managedContext.save()
                }
            } catch {
                // Create, set, and save image generation error AI chat
                await managedContext.perform {
                    let imageGenerationErrorAIChat = Chat(context: managedContext)
                    imageGenerationErrorAIChat.sender = Sender.ai.rawValue
                    imageGenerationErrorAIChat.conversation = conversation
                    imageGenerationErrorAIChat.date = Date()
                    imageGenerationErrorAIChat.text = self.imageGenerationErrorAIMessages.randomElement() ?? self.defaultImageGenerationErrorAIMessage
                    do {
                        try managedContext.save()
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error saving managedContext in ConversationChatGenerator... \(error)")
                    }
                }
                print("Error generating image: \(error)")
                throw error
            }
        } else {
            // Otherwise, do web search as necessary and generate chat
            if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.googleSearchDisabled),
               chatClassifications?.wantsWebSearch ?? false,
               let lastChat = chats.last {
                // Generate and save web search
                try await PersistentGPTWebSearchGenerator.generateSaveWebSearch(
                    authToken: authToken,
                    input: roleAndMessages,
                    to: lastChat,
                    in: managedContext)
                
                // Get webSearch
                if let webSearch = await managedContext.perform({ lastChat.webSearch }) {
                    // Set isLoadingWebSearch to true and current webSearchQuery
                    await MainActor.run {
                        self.isLoadingWebSearch = true
                        self.webSearchQuery = webSearch.query
                    }
                    
                    // Generate and save web search results
                    try await PersistentWebSearcher.searchAndSave(
                        authToken: authToken,
                        webSearch: webSearch,
                        in: managedContext)
                    
                    // Set isLoadingWebSearch to false
                    await MainActor.run {
                        self.isLoadingWebSearch = false
                    }
                }
            }
            // Stream chat
            try await streamChat(
                authToken: authToken,
                isPremium: isPremium,
                model: model,
                additionalBehavior: additionalBehavior,
                conversation: conversation,
                in: managedContext)
        }
    }
    
    private func classifyChat(authToken: String, prompt: String) async throws -> ClassifyChatsSO? {
        // Create StructuredOutputRequest
        let structuredOutputRequest = StructuredOutputRequest(
            authToken: authToken,
            model: .gpt4oMini,
            messages: [
                OAIChatCompletionRequestMessage(
                    role: .user,
                    content: [
                        .text(OAIChatCompletionRequestMessageContentText(text: prompt))
                    ])
            ])
        
        // Get ClassifyChatsSO from HTTPSConnector and return
        let classifyChatsSO: ClassifyChatsSO? = try await StructuredOutputGenerator.generate(
            structuredOutputRequest: structuredOutputRequest,
            endpoint: HTTPSConstants.StructuredOutput.classifyChat)
        
        return classifyChatsSO
    }
    
    private func generateFlashCards(authToken: String, conversation: Conversation, managedContext: NSManagedObjectContext, maxCharacterLimit: Int, maxWebResults: Int, maxWebResultCharacterLimit: Int) async throws {
        // Defer setting isLoadingFlashCards to false
        defer {
            DispatchQueue.main.async {
                self.isLoadingFlashCards = false
            }
        }
        
        // Set isLoadingFlashCards to true
        await MainActor.run {
            isLoadingFlashCards = true
        }
        
        // Create request messages
        let messages = try await ConversationToOAIChatCompletionRequestMessagsAdapter.adapt(
            conversation: conversation,
            in: managedContext,
            maxCharacterLimit: maxCharacterLimit,
            maxWebResults: maxWebResults,
            maxWebResultCharacterLimit: maxWebResultCharacterLimit)
        
        // Create structuredOutputRequest
        let structuredOutputRequest = StructuredOutputRequest(
            authToken: authToken,
            model: .gpt4oMini,
            messages: messages)
        
        // Generate flash card collection
        let flashCardCollection = try await PersistentFlashCardCollectionGenerator.generateSaveFlashCardCollection(
            structuredOutputRequest: structuredOutputRequest,
            in: managedContext)
        
        // Ensure flashCardCollection is not nil
        guard let flashCardCollection = flashCardCollection else {
            alertShowingErrorGeneratingFlashCardCollection = true
            print("Could not unwrap flashCardCollection in ConversationChatGenerator!")
            return
        }
        
        // Get flash cards
        let flashCardsFetchRequest = FlashCard.fetchRequest()
        flashCardsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(FlashCard.flashCardCollection), flashCardCollection)
        flashCardsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FlashCard.index, ascending: true)]
        let flashCards = try await managedContext.perform {
            try managedContext.fetch(flashCardsFetchRequest)
        }
        
        // Transform flash cards to flash card message content
        let flashCardMessageContent: String = "Flash Cards\n" + flashCards.map {
            "Index:\($0.index)\nFront:\($0.front ?? "")\nBack:\($0.back ?? "")"
        }.joined(separator: "\n\n")
        
        // Stream short chat introducing the flash cards
        var shortIntroductionText: String = ""
        do {
            try await ChatGenerator().streamChat(
                getChatRequest: GetChatRequest(
                    authToken: authToken,
                    chatCompletionRequest: OAIChatCompletionRequest(
                        model: GPTModels.gpt4oMini.rawValue,
                        stream: true,
                        messages: [
                            OAIChatCompletionRequestMessage(
                                role: .user,
                                content: [
                                    .text(OAIChatCompletionRequestMessageContentText(text: "Generate a short 1-2 sentence 15-35 word description or summary of the flash cards just generated, also presenting the flash cards to the user. Your message will be used along with the flash cards in presentation to the user. You are not meant to repeat the flash cards, the requested is the only thing you need to include."))
                                ]),
                            OAIChatCompletionRequestMessage(
                                role: .assistant,
                                content: [
                                    .text(OAIChatCompletionRequestMessageContentText(text: flashCardMessageContent))
                                ])
                        ])),
                stream: { chatStreamResponse in
                    if let responseText = chatStreamResponse.body.oaiResponse.choices[safe: 0]?.delta.content {
                        shortIntroductionText += responseText
                    }
                })
        } catch {
            // TODO: Handle Errors
            print("Error streaming chat in ConversationChatGenerator though this may be normal, continuing... \(error)")
        }
        
        // Append Chat with flashCardCollection
        try await ChatCDHelper.appendChat(
            sender: .ai,
            text: shortIntroductionText,
            flashCardCollection: flashCardCollection,
            to: conversation,
            in: managedContext)
    }
}





////
////  ConversationChatGenerator.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 8/5/24.
////
//
//import CoreData
//import Foundation
//import UIKit
//
//// TODO: If the image is being sent the first time send it as high quality otherwise send as low quality
//
//class ConversationChatGenerator: PersistentChatGenerator {
//    
//    @Published var webSearchQuery: String?
//    
//    @Published var alertShowingErrorGeneratingFlashCardCollection = false
//    @Published var alertShowingUserChatNotSaved = false
//    
//    @Published var isShowingPromoImageGenerationView = false
//    @Published var isDisplayingPromoSendImagesView = false
//    
//    @Published var isLoadingFlashCards: Bool = false
//    @Published var isLoadingWebSearch: Bool = false
//    
//    private let defaultAttachmentBehaviorAddition = "You are in an app that allows you to see attachments. How exciting! You will be given a transcription of an attachment or sent an image directly. If you cannot read either, ask the user to try attaching it again."
//    
//    private let defaultImageGenerationErrorAIMessage: String = "Please try generating that again."
//    
//    private let imageGenerationErrorAIMessages: [String] = [
//        "Please try generating that again.",
//        "Hmm, I had an issue generating your image. Please try again and double check your propmt to make sure it's appropriate.",
//        "There was an issue generating your image. Please try rephrasing the prmopt, and make sure it's appropriate.",
//        "There was an issue generating your image. Please try again.",
//        "Hm, I couldn't generate that. Can you try something else?"
//    ]
//    
//    private let maxChatsForClassificationAndImageGeneration: Int = 5
//    
//    private let promoImageGenerationChatText: String = "Please upgrade to generate **unlimited** images.. AI art is created with DALL-E 3, and it's expensive! Thank you 😊"
//    
//    private let promoImageSendChatText: String = "Please upgrade to send **unlimited** images and support the developer. Thank you!"
//    
//    
//    func streamGenerateClassifySaveChat(input: String?, image: UIImage?, imageURL: String?, additionalBehavior: String? = nil, authToken: String, isPremium: Bool, model: GPTModels, to conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
//        // Create User Image URL Chat if imageURL is not nil and User Image Chat if image is not null and User Text Chat if input is not nil and save on main queue
//        let userImageURLChat: Chat? = {
//            // Unwrap imageURL, otherwise return nil
//            guard let imageURL = imageURL else {
//                return nil
//            }
//            
//            return managedContext.performAndWait {
//                let userImageURLChat = Chat(context: managedContext)
//                
//                // Set and save User Image URL Chat
//                userImageURLChat.imageURL = imageURL
//                userImageURLChat.sender = Sender.user.rawValue
//                userImageURLChat.date = Date()
//                userImageURLChat.conversation = conversation
//                
//                return userImageURLChat
//            }
//        }()
//        
//        let userImageChat: Chat? = {
//            // Unwrap image, otherwise return nil
//            guard let image = image else {
//                return nil
//            }
//            
//            return managedContext.performAndWait {
//                let userImageChat = Chat(context: managedContext)
//                
//                // Set and save User Image Chat
//                userImageChat.imageData = image.jpegData(compressionQuality: 0.8)
//                userImageChat.sender = Sender.user.rawValue
//                userImageChat.date = Date().advanced(by: 0.1)
//                userImageChat.conversation = conversation
//                
//                return userImageChat
//            }
//        }()
//        
//        let userTextChat: Chat? = {
//            // Unwrap input and ensure it's not empty, otherwise return nil
//            guard let input = input, !input.isEmpty else {
//                return nil
//            }
//            
//            return managedContext.performAndWait {
//                let userTextChat = Chat(context: managedContext)
//                
//                // Set and save User Text Chat
//                userTextChat.text = input
//                userTextChat.sender = Sender.user.rawValue
//                userTextChat.date = Date().advanced(by: 0.2)
//                userTextChat.conversation = conversation
//                
//                return userTextChat
//            }
//        }()
//        
//        // Update conversation latestChatText to first few characters of input
//        if let input = input {
//            await managedContext.perform {
//                conversation.latestChatText = String(input.prefix(100))
//                conversation.latestChatDate = Date()
//            }
//        }
//        
//        // Save context
//        try await managedContext.perform {
//            try managedContext.save()
//        }
//        
//        // If image or imageURL is included and per ImageSendLimiter by isPremium user cannot send images display promo send images view, add promo image send chat, and return, otherwise if user can send images set shouldIncrementImageSendLimiter to true
//        var shouldIncrementImageSendLimiter = false
//        if !isPremium && (userImageChat != nil || userImageURLChat != nil) {
//            if !ImageSendLimiter.canSendImage(isPremium: isPremium) {
//                await MainActor.run {
//                    // Display send images promo view
//                    self.isDisplayingPromoSendImagesView = true
//                        
//                    managedContext.performAndWait {
//                        // Sned send images promo chat
//                        let promoImageSendChat = Chat(context: managedContext)
//                        promoImageSendChat.conversation = conversation
//                        promoImageSendChat.sender = Sender.ai.rawValue
//                        promoImageSendChat.text = promoImageSendChatText
//                        promoImageSendChat.date = Date()
//                        
//                        do {
//                            try managedContext.save()
//                        } catch {
//                            // TODO: Handle Errors
//                            print("Error saving managedContext in ConversationChatGenerator_Legacy")
//                        }
//                    }
//                }
//                
//                return
//            }
//            
//            shouldIncrementImageSendLimiter = true
//        }
//        
//        // Stream generate chat
//        try await streamGenerateClassifySaveChat(
//            authToken: authToken,
//            isPremium: isPremium,
//            model: model,
//            additionalBehavior: additionalBehavior,
//            conversation: conversation,
//            in: managedContext)
//        
//        // If shouldIncrementImageSendLimiter increment
//        if shouldIncrementImageSendLimiter {
//            ImageSendLimiter.increment()
//        }
//    }
//    
//    func streamGenerateClassifySaveChat(authToken: String, isPremium: Bool, model: GPTModels, additionalBehavior: String? = nil, conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
//        // Defer setting isLoading and isLoadingWebSearch to false
//        defer {
//            DispatchQueue.main.async {
//                self.isLoading = false
//                self.isLoadingWebSearch = false
//            }
//        }
//        
//        // Set isLoading to true
//        await MainActor.run {
//            isLoading = true
//        }
//        
//        // Get Conversation Chats
//        let fetchRequest = Chat.fetchRequest()
////        fetchRequest.fetchLimit = maxChatCount
//        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: true)]
//        let chats = try await managedContext.perform {
//            return try managedContext.fetch(fetchRequest)
//        }
//        
////        // Ensure more than one chat, otherwise return
////        guard chats.count > 0 else {
////            // TODO: Handle errors
////            print("No chats found in Conversation in ConversationChatGenerator!")
////            return
////        }
//        
//        // Transform chats to role and message douple array
//        let roleAndMessages: [(role: CompletionRole, message: String)] = chats.suffix(maxChatsForClassificationAndImageGeneration).map({(role: CompletionRole.from(sender: Sender(rawValue: $0.sender ?? "") ?? .user), message: $0.text ?? "")})
//        
//        // Classify conversation chats
//        let chatClassifications: ClassifyChatsSO? = await {
//            if let lastChatText = chats.last?.text {
//                do {
//                    return try await classifyChat(
//                        authToken: authToken,
//                        prompt: lastChatText)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error classifying chat in ConversationChatGenerator... \(error)")
//                }
//            }
//            return nil
//        }()
//        
//        if chatClassifications?.wantsFlashCards ?? false {
//            // If requests flash cards do flash cards generation
//            try await generateFlashCards(
//                authToken: authToken,
//                conversation: conversation,
//                managedContext: managedContext,
//                maxCharacterLimit: isPremium ? maxCharacterLengthPaid : maxCharacterLengthFree,
//                maxWebResults: isPremium ? maxWebResultsPaid : maxWebResultsFree,
//                maxWebResultCharacterLimit: isPremium ? maxWebResultCharacterLengthPaid : maxWebResultCharacterLengthFree)
//        } else if chatClassifications?.wantsImageGeneration ?? false {
//            // If requests image generation and canGenerateImage do image generation, otherwise do web search as necessary and generate chat
//            if !ImageGenerationLimiter.canGenerateImage(isPremium: isPremium) {
//                // If cannot generate image show promo image generation view and return
//                await MainActor.run {
//                    // Show promo popup for upgrade to generate images and add an AI chat to suggest the user upgrade and return
//                    isShowingPromoImageGenerationView = true
//                    
//                    managedContext.performAndWait {
//                        let promoImageGenerationChat = Chat(context: managedContext)
//                        promoImageGenerationChat.conversation = conversation
//                        promoImageGenerationChat.sender = Sender.ai.rawValue
//                        promoImageGenerationChat.text = promoImageGenerationChatText
//                        promoImageGenerationChat.date = Date()
//                        
//                        do {
//                            try managedContext.save()
//                        } catch {
//                            // TODO: Handle Errors
//                            print("Error saving managedContext in ConversationChatGenerator_Legacy")
//                        }
//                    }
//                }
//                return
//            }
//            
//            // Get imageData
//            let imageData = try await GPTPromptedImageGenerator.generateGPTPromptedImageData(
//                authToken: authToken,
//                chats: roleAndMessages)
//            
//            do {
//                // Create and save Chat with generated image
//                try await managedContext.perform {
//                    let aiChat = Chat(context: managedContext)
//                    
//                    aiChat.sender = Sender.ai.rawValue
//                    aiChat.imageData = imageData
//                    aiChat.date = Date()
//                    aiChat.conversation = conversation
//                    
//                    try managedContext.save()
//                }
//            } catch {
//                // Create, set, and save image generation error AI chat
//                await managedContext.perform {
//                    let imageGenerationErrorAIChat = Chat(context: managedContext)
//                    
//                    imageGenerationErrorAIChat.sender = Sender.ai.rawValue
//                    imageGenerationErrorAIChat.conversation = conversation
//                    imageGenerationErrorAIChat.date = Date()
//                    imageGenerationErrorAIChat.text = self.imageGenerationErrorAIMessages.randomElement() ?? self.defaultImageGenerationErrorAIMessage
//                    
//                    do {
//                        try managedContext.save()
//                    } catch {
//                        // TODO: Handle Errors if Necessary
//                        print("Error saving managedContext in ConversationChatGenerator_Legacy... \(error)")
//                    }
//                }
//                
//                print("Error generating image: \(error)")
//                throw error
//            }
//        } else {
//            // Otherwise do web search as necessary and generate chat
//            
//            // If requests web search and google search is not disabled get the web search added to the chat
//            if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.googleSearchDisabled) && chatClassifications?.wantsWebSearch ?? false,
//               let lastChat = chats.last {
//                // TODO: Set isSearchingWeb
//                
//                // Generate save web search
//                try await PersistentGPTWebSearchGenerator.generateSaveWebSearch(
//                    authToken: authToken,
//                    input: roleAndMessages,
//                    to: lastChat,
//                    in: managedContext)
//                
//                // Get webSearch
//                if let webSearch = await managedContext.perform({
//                    lastChat.webSearch
//                }) {
//                    // Set isLoadingWebSearch to true and current webSearchQuery
//                    await MainActor.run {
//                        self.isLoadingWebSearch = true
//                        self.webSearchQuery = webSearch.query
//                    }
//                    
//                    // Generate save web search results
//                    try await PersistentWebSearcher.searchAndSave(
//                        authToken: authToken,
//                        webSearch: webSearch,
//                        in: managedContext)
//                    
//                    // Set isLoadingWebSearch to false
//                    await MainActor.run {
//                        self.isLoadingWebSearch = false
//                    }
//                }
//            }
//            
//            // Stream chat
//            try await streamChat(
//                authToken: authToken,
//                isPremium: isPremium,
//                model: model,
//                additionalBehavior: additionalBehavior,
//                conversation: conversation,
//                in: managedContext)
//        }
//    }
//    
//    private func classifyChat(authToken: String, prompt: String) async throws -> ClassifyChatsSO? {
//        // Create StructuredOutputRequest
//        let structuredOutputRequest = StructuredOutputRequest(
//            authToken: authToken,
//            model: .gpt4oMini,
//            messages: [
//                OAIChatCompletionRequestMessage(
//                    role: .user,
//                    content: [
//                        .text(OAIChatCompletionRequestMessageContentText(text: prompt))
//                    ])
//            ])
//        
//        // Get ClassifyChatsSO from HTTPSConnector and return
//        let classifyChatsSO: ClassifyChatsSO? = try await StructuredOutputGenerator.generate(
//            structuredOutputRequest: structuredOutputRequest,
//            endpoint: HTTPSConstants.StructuredOutput.classifyChat)
//        
//        return classifyChatsSO
//    }
//    
//    private func generateFlashCards(authToken: String, conversation: Conversation, managedContext: NSManagedObjectContext, maxCharacterLimit: Int, maxWebResults: Int, maxWebResultCharacterLimit: Int) async throws {
//        // Defer setting isLoadingFlashCards to false
//        defer {
//            DispatchQueue.main.async {
//                self.isLoadingFlashCards = false
//            }
//        }
//        
//        // Set isLoadingFlashCards to true
//        await MainActor.run {
//            isLoadingFlashCards = true
//        }
//        
//        // Create request messages
//        let messages = try await ConversationToOAIChatCompletionRequestMessagsAdapter.adapt(
//            conversation: conversation,
//            in: managedContext,
//            maxCharacterLimit: maxCharacterLimit,
//            maxWebResults: maxWebResults,
//            maxWebResultCharacterLimit: maxWebResultCharacterLimit)
//        
//        // Create structuredOutputRequest
//        let structuredOutputRequest = StructuredOutputRequest(
//            authToken: authToken,
//            model: .gpt4oMini,
//            messages: messages)
//        
//        // Generate flash card collection
//        let flashCardCollection = try await PersistentFlashCardCollectionGenerator.generateSaveFlashCardCollection(
//            structuredOutputRequest: structuredOutputRequest,
//            in: managedContext)
//        
//        // Ensure unwrap flashCardCollection, otherwise show error alert and return
//        guard let flashCardCollection = flashCardCollection else {
//            alertShowingErrorGeneratingFlashCardCollection = true
//            print("Could not unwrap flashCardCollection in COnversationChatGenerator!")
//            return
//        }
//        
//        // Get flash cards
//        let flashCardsFetchRequest = FlashCard.fetchRequest()
//        flashCardsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(FlashCard.flashCardCollection), flashCardCollection)
//        flashCardsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FlashCard.index, ascending: true)]
//        let flashCards = try await managedContext.perform {
//            try managedContext.fetch(flashCardsFetchRequest)
//        }
//        
//        // Transform flash cards to flash card message content TODO: This logic should be abstracted somewhere
//        let flashCardMessageContent: String = "Flash Cards\n" + flashCards.map({"Index:\($0.index)\nFront:\($0.front ?? "")\nBack:\($0.back ?? "")"}).joined(separator: "\n\n")
//        
//        // Steram short chat introducing the flash cards
//        var shortIntroductionText: String = ""
//        do {
//            try await ChatGenerator().streamChat(
//                getChatRequest: GetChatRequest(
//                    authToken: authToken,
//                    chatCompletionRequest: OAIChatCompletionRequest(
//                        model: GPTModels.gpt4oMini.rawValue,
//                        stream: true,
//                        messages: [
//                            OAIChatCompletionRequestMessage( // TODO: Should this be first or second, which is the correct order? Pretty sure the newest chats are at the 0 index
//                                role: .user,
//                                content: [
//                                    .text(OAIChatCompletionRequestMessageContentText(text: "Generate a short 1-2 sentence 15-35 word description or summary of the flash cards just generated, also presenting the flash cards to the user. Your message will be used along with the flash cards in presentation to the user. You are not meant to repeat the flash cards, the requested is the only thing you need to include."))
//                                ]),
//                            OAIChatCompletionRequestMessage(
//                                role: .assistant,
//                                content: [
//                                    .text(OAIChatCompletionRequestMessageContentText(text: flashCardMessageContent))
//                                ])
//                        ])),
//                stream: { chatStreamResponse in
//                    if let responseText = chatStreamResponse.body.oaiResponse.choices[safe: 0]?.delta.content {
//                        shortIntroductionText += responseText
//                    }
//                })
//        } catch {
//            // TODO: Handle Errors
//            print("Error streaming chat in ConversationChatGenerator though this may be normal, continuing... \(error)")
//        }
//        
//        // Append Chat with flashCardCollection
//        try ChatCDHelper.appendChat(
//            sender: .ai,
//            text: shortIntroductionText,
//            flashCardCollection: flashCardCollection,
//            to: conversation,
//            in: managedContext)
//    }
//    
//    /**
//     Gets..
//     - Persistent attachment images, like if a user adds an image initially
//     - Keep in mind images TODO: There should be checks to make sure the user is not keeping in mind more than one image if they are free but that can be somewhere else
//     */
//    private func getAllPersistentImagesData(conversation: Conversation, in managedContext: NSManagedObjectContext) async throws -> [Data] {
//        // Get most recent persistent attachment
//        let fetchRequest = PersistentAttachment.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)]
//        fetchRequest.fetchLimit = 1
//        
//        let persistentAttachment = try await managedContext.perform {
//            try managedContext.fetch(fetchRequest)[safe: 0]
//        }
//        
//        // Persistent attachment image data
//        let persistentAttachmentImageData: Data? = {
//            do {
//                if let persistentAttachment = persistentAttachment,
//                   let attachmentTypeString = persistentAttachment.attachmentType,
//                   let attachmentType = AttachmentType(rawValue: attachmentTypeString),
//                   attachmentType == .image,
//                   let documentsFilePath = persistentAttachment.documentsFilePath,
//                   let attachmentImage = try DocumentSaver.getImage(from: documentsFilePath) {
//                    return attachmentImage.pngData()
//                }
//            } catch {
//                // TODO: Handle Errors if Necessary
//                print("Error getting image for attachment in ConversationChatGenerator_Legacy... \(error)")
//            }
//            
//            return nil
//        }()
//        
//        // Create keepingInMindFirstImageData if there is an image that is kept in mind, specifically the first one when sorting from newest to oldest though other places should prevent duplicates
//        let keepingInMindFirstImageData: [Data?] = {
//            do {
//                return try ConversationCDHelper.getKeepingInMindImageDataRecentFirst(
//                    conversation: conversation,
//                    in: managedContext) ?? [] // TODO: Remove the safe: 0 and make keepingInMindFirstImageData an array of images data when converting to multiple images in keep in mind
//            } catch {
//                // TODO: Handle Errors
//                print("Error getting first keeping in mind image data in ConversationChatGenerator_Legacy... \(error)")
//                return []
//            }
//        }()
//        
//        // Return array of all persistent images data with a compact map to [Data] array, basically this way removes nil data from the array to be sent
//        return ([persistentAttachmentImageData] + keepingInMindFirstImageData).compactMap({$0})
//    }
//    
//}
