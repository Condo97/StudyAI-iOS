//
//  ConversationCDHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import CoreData
import Foundation

class ConversationCDHelper: Any {
    
    static let conversationEntityName = String(describing: Conversation.self)
    
    static func appendConversation(modelID: String, in managedContext: NSManagedObjectContext) async throws -> Conversation {
        // Create Assistant
        let assistant: Assistant?
        do {
            if let mostRecentAssistant = try await ConversationCDHelper.getMostRecentAssistant(in: CDClient.mainManagedObjectContext) {
                assistant = mostRecentAssistant
            } else {
                // Set to most popular featured Assistant TODO: Handle if there is no most popular assistant
                if let mostPopularFeaturedAssistant = try await AssistantCDHelper.getMostPopularFeaturedAssistant(in: CDClient.mainManagedObjectContext) {
                    // Set to first Assistant
                    assistant = mostPopularFeaturedAssistant
                } else {
                    // Set featured Assistant to nil TODO: Handle if there is no most popular featured assistant
                    assistant = nil
                }
            }
        } catch {
            // TODO: Handle Errors
            print("Error getting Assistant in ChatView... \(error)")
            
            // Set to most popular featured Assistant TODO: Handle if there is no most popular assistant
            if let mostPopularFeaturedAssistant = try await AssistantCDHelper.getMostPopularFeaturedAssistant(in: CDClient.mainManagedObjectContext) {
                // Set to first Assistant
                assistant = mostPopularFeaturedAssistant
            } else {
                // Set featured Assistant to nil TODO: Handle if there is no most popular featured assistant
                assistant = nil
            }
        }
        
        // Create new Conversation
        let conversation = try await ConversationCDHelper.appendConversation(
            modelID: modelID,
            assistant: assistant,
            in: CDClient.mainManagedObjectContext)
        
        return conversation
    }
    
    static func appendConversation(modelID: String, assistant: Assistant?, in managedContext: NSManagedObjectContext) async throws -> Conversation {
        return try await appendConversation(conversationID: Int64(Constants.defaultConversationID), modelID: modelID, assistant: assistant, in: managedContext)
    }
    
    static func appendConversation(conversationID: Int64, modelID: String, in managedContext: NSManagedObjectContext) async throws -> Conversation {
        return try await appendConversation(conversationID: conversationID, modelID: modelID, assistant: nil, in: managedContext)
    }
    
    static func appendConversation(conversationID: Int64, modelID: String, assistant: Assistant?, in managedContext: NSManagedObjectContext) async throws -> Conversation {
        // Could also do it this way, but I think the way I have it now is cooler!
//            let keyValueMap: Dictionary<String, Any> = [
//                #keyPath(Conversation.conversationID):conversationID,
//                #keyPath(Conversation.behavior):behavior!
//            ]
        
//            return try CDClient.append(keyValueMap: keyValueMap, in: conversationEntityName) as! Conversation
        
        let conversation = Conversation(context: managedContext)
        
        conversation.conversationID = conversationID
        conversation.assistant = assistant
        
        // Set behavior to assistant systemPrompt since it will be able to be modified by user TODO: Is this okay and a good way to do this
        conversation.behavior = assistant?.systemPrompt
        
        // Set modelName
        conversation.modelID = modelID
        
        return try await managedContext.perform {
            try managedContext.save()
            
            return conversation
        }
        
    }
    
    static func appendConversation(modelID: String, in managedContext: NSManagedObjectContext) throws -> Conversation {
        // Create Assistant
        let assistant: Assistant?
        do {
            if let mostRecentAssistant = try ConversationCDHelper.getMostRecentAssistant(in: CDClient.mainManagedObjectContext) {
                assistant = mostRecentAssistant
            } else {
                // Set to most popular featured Assistant TODO: Handle if there is no most popular assistant
                if let mostPopularFeaturedAssistant = try AssistantCDHelper.getMostPopularFeaturedAssistant(in: CDClient.mainManagedObjectContext) {
                    // Set to first Assistant
                    assistant = mostPopularFeaturedAssistant
                } else {
                    // Set featured Assistant to nil TODO: Handle if there is no most popular featured assistant
                    assistant = nil
                }
            }
        } catch {
            // TODO: Handle Errors
            print("Error getting Assistant in ChatView... \(error)")
            
            // Set to most popular featured Assistant TODO: Handle if there is no most popular assistant
            if let mostPopularFeaturedAssistant = try AssistantCDHelper.getMostPopularFeaturedAssistant(in: CDClient.mainManagedObjectContext) {
                // Set to first Assistant
                assistant = mostPopularFeaturedAssistant
            } else {
                // Set featured Assistant to nil TODO: Handle if there is no most popular featured assistant
                assistant = nil
            }
        }
        
        // Create new Conversation
        let conversation = try ConversationCDHelper.appendConversation(
            modelID: modelID,
            assistant: assistant,
            in: CDClient.mainManagedObjectContext)
        
        return conversation
    }
    
    static func appendConversation(modelID: String, assistant: Assistant?, in managedContext: NSManagedObjectContext) throws -> Conversation {
        return try appendConversation(conversationID: Int64(Constants.defaultConversationID), modelID: modelID, assistant: assistant, in: managedContext)
    }
    
    static func appendConversation(conversationID: Int64, modelID: String, in managedContext: NSManagedObjectContext) throws -> Conversation {
        return try appendConversation(conversationID: conversationID, modelID: modelID, assistant: nil, in: managedContext)
    }
    
    static func appendConversation(conversationID: Int64, modelID: String, assistant: Assistant?, in managedContext: NSManagedObjectContext) throws -> Conversation {
        // Could also do it this way, but I think the way I have it now is cooler!
//            let keyValueMap: Dictionary<String, Any> = [
//                #keyPath(Conversation.conversationID):conversationID,
//                #keyPath(Conversation.behavior):behavior!
//            ]
        
//            return try CDClient.append(keyValueMap: keyValueMap, in: conversationEntityName) as! Conversation
        
        return try managedContext.performAndWait {
            let conversation = Conversation(context: managedContext)
            
            // Set conversationID and assistant
            conversation.conversationID = conversationID
            conversation.assistant = assistant
            
            // Set behavior to assistant systemPrompt since it will be able to be modified by user TODO: Is this okay and a good way to do this
            conversation.behavior = assistant?.systemPrompt
            
            // Set modelID based on assistant's premium value TODO: Is there a better way I should do this? Maybe just keep the previously selected GPT model or something? Idk this seems fine
            conversation.modelID = modelID//assistant?.premium ?? false ? GPTModels.gpt4.rawValue : GPTModels.gpt3turbo.rawValue
        
            try managedContext.save()
            
            return conversation
        }
        
    }
    
    static func countConversations(in managedContext: NSManagedObjectContext) async throws -> Int {
        try await managedContext.perform {
            let fetchRequest = Conversation.fetchRequest()
            
            return try managedContext.count(for: fetchRequest)
        }
    }
    
    static func deleteConversation(conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        managedContext.delete(conversation)
        
        try await managedContext.perform {
            try managedContext.save()
        }
    }
    
    static func getConversation(modelID: String, in managedContext: NSManagedObjectContext) throws -> Conversation {
        do {
            if let conversation = try ConversationResumingManager.getConversation(in: managedContext) {
                return conversation
            } else {
                // Set to new Conversation
                do {
                    return try ConversationCDHelper.appendConversation(modelID: modelID, in: managedContext)
                } catch {
                    // TODO: Handle errors
                    print("Error appending Conversation in ConversationCDHelper... \(error)")
                    throw error
                }
            }
        } catch {
            // TODO: Handle errors
            print("Error resuming Conversation in ConversationCDHelper... \(error)")
            
            // Set to new Conversation
            do {
                return try ConversationCDHelper.appendConversation(modelID: modelID, in: managedContext)
            } catch {
                // TODO: Handle errors
                print("Error appending Conversation in ConversationCDHelper... \(error)")
                throw error
            }
        }
    }
    
    static func getFirstAIChatImageData(maxIndex: Int, for conversation: Conversation, in managedContext: NSManagedObjectContext) throws -> Data? {
        return try getFirstChatImageData(
            maxIndex: maxIndex,
            sender: .ai,
            for: conversation,
            in: managedContext)
    }
    
    static func getFirstUserChatImageData(maxIndex: Int, for conversation: Conversation, in managedContext: NSManagedObjectContext) throws -> Data? {
        return try getFirstChatImageData(
            maxIndex: maxIndex,
            sender: .user,
            for: conversation,
            in: managedContext)
    }
    
    static func getFirstChatImageData(maxIndex: Int, sender: Sender, for conversation: Conversation, in managedContext: NSManagedObjectContext) throws -> Data? {
        return try getFirstChatImageData(
            maxIndex: maxIndex,
            senderString: sender.rawValue,
            for: conversation,
            in: managedContext)
    }
    
    static func getFirstChatImageData(maxIndex: Int, senderString: String, for conversation: Conversation, in managedContext: NSManagedObjectContext) throws -> Data? {
        let fetchRequest = Chat.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)]
//        fetchRequest.predicate = NSPredicate(format: "%K = %@ and %K = %@ and %K.length > 0", #keyPath(Chat.conversation), conversation, #keyPath(Chat.sender), senderString, #keyPath(Chat.imageData))
        fetchRequest.predicate = NSPredicate(format: "%K = %@ and %K = %@", #keyPath(Chat.conversation), conversation, #keyPath(Chat.sender), senderString)
        fetchRequest.fetchLimit = maxIndex
        
        return try managedContext.performAndWait {
            // Fetch results
            let results = try managedContext.fetch(fetchRequest)
            
            // Return the first occurence in results that includes imageData
            for result in results {
                if let imageData = result.imageData {
                    return imageData
                }
            }
            
            // Otherwise, return nil
            return nil
        }
    }
    
    static func getFavorited(conversation: Conversation, in managedContext: NSManagedObjectContext) throws -> [Chat] {
        let fetchRequest = Chat.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@ and %K = %d", #keyPath(Chat.conversation), conversation, #keyPath(Chat.favorited), true)
        
        return try managedContext.performAndWait {
            return try managedContext.fetch(fetchRequest)
        }
    }
    
    static func getKeepingInMind(conversation: Conversation, in managedContext: NSManagedObjectContext) throws -> [Chat] {
        let fetchRequest = Chat.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@ and %K = %d", #keyPath(Chat.conversation), conversation, #keyPath(Chat.keepInMind), true)
        
        return try managedContext.performAndWait {
            return try managedContext.fetch(fetchRequest)
        }
    }
    
    static func getKeepingInMindImageDataRecentFirst(conversation: Conversation, in managedContext: NSManagedObjectContext) throws -> [Data]? {
        let fetchRequest = Chat.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@ and %K = %d and %K.length > 0", #keyPath(Chat.conversation), conversation, #keyPath(Chat.keepInMind), true, #keyPath(Chat.imageData))
//        fetchRequest.fetchLimit = 1
        
        return try managedContext.performAndWait {
            let results = try managedContext.fetch(fetchRequest)
            
            return results.compactMap({$0.imageData})
        }
    }
    
    static func getMostRecentAssistant(in managedContext: NSManagedObjectContext) throws -> Assistant? {
        let fetchRequest = Conversation.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Conversation.latestChatDate), ascending: false)]
        
        return try managedContext.performAndWait {
            let results = try managedContext.fetch(fetchRequest)
            
            for result in results {
                if let assistant = result.assistant {
                    return assistant
                }
            }
            
            return nil
        }
    }
    
    static func getMostRecentAssistant(in managedContext: NSManagedObjectContext) async throws -> Assistant? {
        let fetchRequest = Conversation.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Conversation.latestChatDate), ascending: false)]
        
        return try await managedContext.perform {
            let results = try managedContext.fetch(fetchRequest)
            
            for result in results {
                if let assistant = result.assistant {
                    return assistant
                }
            }
            
            return nil
        }
    }
    
    static func hasMaxKeepInMindImageData(maxCount: Int, for conversation: Conversation, in managedContext: NSManagedObjectContext) throws -> Bool {
        let fetchRequest = Chat.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@ and %K = %d and %K.length > 0", #keyPath(Chat.conversation), conversation, #keyPath(Chat.keepInMind), true, #keyPath(Chat.imageData))
        fetchRequest.fetchLimit = maxCount
        
        return try managedContext.performAndWait {
            let results = try managedContext.fetch(fetchRequest)
            
            return results.count >= maxCount
        }
    }
    
    static func removeAssistantTextFromBehavior(for conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap assistantText, otherwise return
        guard let assistantText = conversation.assistant?.systemPrompt else {
            return
        }
        
        // Ensure assistantText equals behavior, otherwise return
        guard assistantText == conversation.behavior else {
            return
        }
        
        // Set and save conversation behavior to nil
        try await managedContext.perform {
            conversation.behavior = nil
            
            try managedContext.save()
        }
    }
    
    static func removeKeepInMindOldestChatWithImageData(for conversation: Conversation, in managedContext: NSManagedObjectContext) throws {
        let fetchRequest = Chat.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@ and %K = %d and %K.length > 0", #keyPath(Chat.conversation), conversation, #keyPath(Chat.keepInMind), true, #keyPath(Chat.imageData))
        
        try managedContext.performAndWait {
            let results = try managedContext.fetch(fetchRequest)
            
            if results.count > 0, let lastChat = results.last {
                lastChat.keepInMind = false
                
                try managedContext.save()
            }
        }
    }
    
}
