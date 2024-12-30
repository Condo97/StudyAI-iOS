////
////  LiveSpeechGenerator.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 9/5/24.
////
//
//import Foundation
//import CoreData
//
//@MainActor
//class LiveSpeechGenerator: ObservableObject {
//    
//    @Published var isLoading: Bool = false
//    
//    private var currentlyQueuedSpeechToGenerateFromStreamingChat: String = ""
//    
//    private var interruptLoadNextTTS: Bool = false
//    
//    private var loadNextTTSTask: Task<Void, Never>?
//    
//    func loadNextTTS(conversation: Conversation, speechSpeed: Double, speechVoice: SpeechVoices, conversationChatGenerator: ConversationChatGenerator, queuedAudioPlayer: QueuedAudioPlayer, in managedContext: NSManagedObjectContext) {
//        // Reset interrupt load next TTS flag to ensure it loads successfully as this is the publicly exposed function
//        interruptLoadNextTTS = false
//        
//        // Reset currentlyQueuedSpeechToGenerateFromStreamingChat
//        currentlyQueuedSpeechToGenerateFromStreamingChat = ""
//        
//        DispatchQueue.main.async {
//            self.loadNextTTSTask = Task {
//                defer {
//                    self.isLoading = false
//                }
//                
//                await MainActor.run {
//                    self.isLoading = true
//                }
//                
//                await self.loadNextTTSInterruptable(
//                    conversation: conversation,
//                    speechSpeed: speechSpeed,
//                    speechVoice: speechVoice,
//                    conversationChatGenerator: conversationChatGenerator,
//                    queuedAudioPlayer: queuedAudioPlayer,
//                    in: managedContext)
//            }
//        }
//    }
//    
//    func interrupt() {
//        DispatchQueue.main.async {
//            self.loadNextTTSTask?.cancel()
//            self.interruptLoadNextTTS = true
//        }
//    }
//    
//    private func loadNextTTSInterruptable(conversation: Conversation, speechSpeed: Double, speechVoice: SpeechVoices, conversationChatGenerator: ConversationChatGenerator, queuedAudioPlayer: QueuedAudioPlayer, in managedContext: NSManagedObjectContext) async {
//        // Get the currently streaming chat
//        let currentStreamingChat: String? = {
//            // If streamingChat can be unwrapped use it
//            if let streamingChat = conversationChatGenerator.streamingChat {
//                return streamingChat
//            }
//            
//            // Otherwise use the most recent chat from conversation
//            let fetchRequest = Chat.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
//            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
//            fetchRequest.fetchLimit = 1
//            do {
//                let chat = try managedContext.performAndWait {
//                    return try managedContext.fetch(fetchRequest)[safe: 0]
//                }
//                
//                if let chatText = chat?.text {
//                    return chatText
//                }
//            } catch {
//                // TODO: Handle Errors
//                print("Error fetching chat in LiveSpeechContainer... \(error)")
//            }
//            
//            // Otherwise return nil
//            return nil
//        }()
//        
//        // Ensure unwrap currently streaming chat
//        guard let currentStreamingChat = currentStreamingChat else {
//            // TODO: Handle Errors
//            return
//        }
//        
//        // Ensure authToken
//        let authToken: String
//        do {
//            authToken = try await AuthHelper.ensure()
//        } catch {
//            // TODO: Handle Errors
//            print("Error ensuring authToken in LiveSpeechContainer... \(error)")
//            return
//        }
//        
//        do {
//            // If isGenerating use up to the latest sentence and then subtract currentlyQueuedSpeechToGenerateFromStreamingChat from it
//            // If not isGenerating use the entire thing and subtract currentlyQueuedSpeechToGenerateFromStreamingChat from it
//            // The purpose is to make sure that sentences are spoken in whole parts
//            
//            // Get the chat text to speak from the current chat minus currentlyQueuedSpeechToGenerateFromStreamingChat
//            let currentStreamingChatRemovingCurrentlyQueuedSpeechToGenerateFromStreamingChat: String
//            if conversationChatGenerator.isGenerating {
//                // If isGenerating use up to the latest sentence and then subtract currentlyQueuedSpeechToGenerateFromStreamingChat from it
//                currentStreamingChatRemovingCurrentlyQueuedSpeechToGenerateFromStreamingChat = parseToLatestSentence(from: currentStreamingChat).replacingOccurrences(of: currentlyQueuedSpeechToGenerateFromStreamingChat, with: "")
//            } else {
//                // If not isGenerating use the entire thing and subtract currentlyQueuedSpeechToGenerateFromStreamingChat from it
//                currentStreamingChatRemovingCurrentlyQueuedSpeechToGenerateFromStreamingChat = currentStreamingChat.replacingOccurrences(of: currentlyQueuedSpeechToGenerateFromStreamingChat, with: "")
//            }
//            
//            // Ensure the text to speak is not empty, otherwise set isSpeakingChat to false and return
//            guard !currentStreamingChatRemovingCurrentlyQueuedSpeechToGenerateFromStreamingChat.isEmpty else {
//                return
//            }
//            
//            // Generate speech
//            let speech = try await SpeechGenerator.generateSpeech(
//                authToken: authToken,
//                input: currentStreamingChatRemovingCurrentlyQueuedSpeechToGenerateFromStreamingChat,
//                speed: speechSpeed,
//                voice: speechVoice)
//            
//            // Update currently queued speech to generate from streaming chat with current streaming chat
//            await MainActor.run {
//                currentlyQueuedSpeechToGenerateFromStreamingChat = currentlyQueuedSpeechToGenerateFromStreamingChat + currentStreamingChatRemovingCurrentlyQueuedSpeechToGenerateFromStreamingChat //currentStreamingChat Replaced with this addition to ensure that the currentlyQueuedSpeechToGenerateFromStreamingChat does not contain extra words if it has been clipped to a sentence, this should be fine though since when creating the currentStreamingChatRemovingCurrentlyQueuedSpeechToGenerateFromStreamingChat if it clips out currentlyQueuedSpeechToGenerateFromStreamingChat it should preserve the white space before the first word
//            }
//            
//            try Task.checkCancellation()
//            
//            await queuedAudioPlayer.queue(data: speech) // Queue the audio
//            
//            await loadNextTTSInterruptable(
//                conversation: conversation,
//                speechSpeed: speechSpeed,
//                speechVoice: speechVoice,
//                conversationChatGenerator: conversationChatGenerator,
//                queuedAudioPlayer: queuedAudioPlayer,
//                in: managedContext)
//        } catch {
//            print("Error generating or playing speech: \(error)")
//        }
//    }
//    
//    func parseToLatestSentence(from input: String) -> String {
//        // Define a regular expression pattern for sentence-ending punctuation
//        let sentenceEndingPattern = "[.!?]"
//        
//        // Create a regular expression instance
//        let regex = try! NSRegularExpression(pattern: sentenceEndingPattern, options: [])
//        
//        // Find the range of the last occurrence of a sentence-ending punctuation
//        if let match = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)).last {
//            // Get the range of the last match
//            let endOfLastSentence = match.range
//            // Get substring up to and including the last sentence-ending character
//            let upToLastSentence = (input as NSString).substring(to: endOfLastSentence.location + 1)
//            return upToLastSentence
//        } else {
//            // No sentence-ending punctuation found, return the original input
//            return input
//        }
//    }
//    
//}
