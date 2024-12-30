//
//  LiveSpeechContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/23/24.
//

import AVKit
import SwiftUI
import OpenAI

@available(iOS 17, *)
@MainActor
struct LiveSpeechContainer: View {
    
//    var assistant: Assistant?
//    var attachment: PersistentAttachment?
    @Binding var isPresented: Bool
    var conversation: Conversation
//    @ObservedObject var conversationChatGenerator: ConversationChatGenerator
    @FetchRequest var persistentAttachments: FetchedResults<PersistentAttachment>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var constantsUpdater: ConstantsUpdater
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
//    @StateObject private var conversationChatGenerator: ConversationChatGenerator = ConversationChatGenerator()
//    @StateObject private var liveSpeechAudioSessionUpdater: LiveSpeechAudioSessionUpdater = LiveSpeechAudioSessionUpdater()
//    @StateObject private var liveSpeechGenerator: LiveSpeechGenerator = LiveSpeechGenerator()
//    @StateObject private var queuedAudioPlayer: QueuedAudioPlayer = QueuedAudioPlayer()
//    @StateObject private var speechTranscriber: SpeechTranscriber = SpeechTranscriber()
    
//    @State private var realtimeOpenAIConversation = realtimeOpenAIConversation(authToken: "asdf")
//    @StateObject private var liveSpeechActor = LiveSpeechObservableObject()
    @MainActor @State var realtimeOpenAIConversation = RealtimeOpenAIConversation(authToken: "asdf")
    
    @State private var isCancelled: Bool = false
    
    @State private var pendingChats: [Item.Message: Chat] = [:]
    @State private var completedAndSavedChats: [Item.Message] = []
    
    @State private var setInitialSession: Bool = false
    
    @State private var speakingBubbleState: LiveSpeechView.SpeakingBubbleStates = .connecting
//    private var speakingBubbleState: LiveSpeechView.SpeakingBubbleStates {
//        if isCancelled {
//            return .none
//        } else {
//            if tapIntermittentToActive {
//                return .listeningAutoActive
//            }
//            if tapIntermittentToInactive {
//                return .none
//            }
//            
//            if !realtimeOpenAIConversation.connected {
//                return .connecting
//            }
//            if realtimeOpenAIConversation.isListening {
//                return .listeningAutoActive
//            }
//            if realtimeOpenAIConversation.isPlaying {
//                return .speakingActive
//            }
//            return .none
            
//            if realtimeOpenAIConversation.is liveSpeechGenerator.isLoading || queuedAudioPlayer.isQueuePlaying || conversationChatGenerator.isGenerating {
//                return .speakingActive
//            } else {
//                if speechTranscriber.isListening && !speechTranscriber.isPaused {
//                    if speechTranscriber.isManualListeningEnabled {
//                        return .listeningManualActive
//                    } else {
//                        if speechTranscriber.liveTranscribedText.isEmpty {
//                            return .listeningWaiting
//                        } else {
//                            return .listeningAutoActive
//                        }
//                    }
//                } else {
//                    if conversationChatGenerator.isLoading {
//                        return .speakingLoading
//                    } else {
//                        return .none
//                    }
//                }
//            }
//        isCancelled ? .none : isSpeakingChat ? .speakingActive : speechTranscriber.isListening ? (speechTranscriber.isManualListeningEnabled ? .listeningManualActive : (speechTranscriber.liveTranscribedText.isEmpty ? .listeningWaiting : .listeningAutoActive)) : conversationChatGenerator.isLoading ? .speakingLoading : .none
//    }
    
    private var pauseButtonState: LiveSpeechView.PauseButtonState {
        // The pause button is only shown as a pause button when AI is listening. The pause button pauses the listening and turns into a play button. When the AI is talking, a stop button is shown that cancels the speach and restarts listening.
        if !realtimeOpenAIConversation.connected {
            return .connecting
        }
        if realtimeOpenAIConversation.isListening {
            return .pause
        }
        if realtimeOpenAIConversation.isPlaying {
            return .stop
        }
        return .play
        
//        if realtimeOpenAIConversation.isListening {
//            return .pause
//        } else {
//            if liveSpeechGenerator.isLoading || queuedAudioPlayer.isQueuePlaying || conversationChatGenerator.isLoading || conversationChatGenerator.isGenerating {
//                return .stop
//            } else {
//                if speechTranscriber.isListening && !speechTranscriber.isPaused {
//                    return .pause
//                } else {
//                    return .play
//                }
//            }
//        }
//        isCancelled ? .play : isSpeakingChat || conversationChatGenerator.isLoading ? .stop : speechTranscriber.isListening ? .pause : .play
    }
    
    var body: some View {
        VStack {
            LiveSpeechView(
                pauseButtonState: pauseButtonState,
                audioLevels: realtimeOpenAIConversation.userFrequencyVolumes, //[CGFloat.random(in: 0..<100), CGFloat.random(in: 0..<100), CGFloat.random(in: 0..<100), CGFloat.random(in: 0..<100)], // TODO: Update this with the response with GPT
                assistant: conversation.assistant,
                attachment: persistentAttachments.first,
                speakingBubbleState: speakingBubbleState,
                aiBubbleVolume: realtimeOpenAIConversation.returnedAudioVolume,
                userBubbleVolume: realtimeOpenAIConversation.userVolume,
//                isUsingEarpiece: $liveSpeechAudioSessionUpdater.isUsingEarpiece,
                onStopAll: onStopAll,
                onPausePlayActionButtonPressed: onPausePlayActionButtonPressed,
                onBeginManualListening: {
//                    // Set manual listening enabled to true to ensure the silence timer does not stop recording
//                    speechTranscriber.isManualListeningEnabled = true
                },
                onEndManualListening: {
//                    // If manual listening is enabled stop recording manually
//                    if speechTranscriber.isManualListeningEnabled {
//                        speechTranscriber.stopListening()
//                    }
                },
                onDismiss: {
                    isPresented = false
                })
        }
        .background(Colors.background)
        .onDisappear {
            onStopAll()
        }
        .onChange(of: realtimeOpenAIConversation.connected) { newValue in
            if !newValue {
                print("Disconnected!")
                isPresented = false
            }
        }
        .onChange(of: realtimeOpenAIConversation.session) { newValue in
            if newValue != nil && !setInitialSession {
                // Set setInitialSession to true
                setInitialSession = true
                
                // Update session
                updateSession()
            }
        }
        .onChange(of: realtimeOpenAIConversation.isListening) { newValue in
            if newValue {
                withAnimation {
                    speakingBubbleState = .listeningAutoActive
                }
            }
        }
        .onChange(of: realtimeOpenAIConversation.isPlaying) { newValue in
            if newValue {
                withAnimation {
                    speakingBubbleState = .speakingActive
                }
            }
            
            if newValue {
                realtimeOpenAIConversation.stopListening()
            } else {
                do {
                    try realtimeOpenAIConversation.startListening()
                } catch {
                    // TODO: Handle Errors
                    print("Error starting listening in LiveSpeechContainer... \(error)")
                    return
                }
            }
        }
        .onChange(of: realtimeOpenAIConversation.messages) { newValue in
//            let notSavedOrPendingChats = newValue.filter({ !pendingChats.contains(where: { $0.id == $1.id }) && !savedChats.contains(where: { $0.id == $1.id })})
//            let notSavedOrPendingChats = newValue.filter { message in
//                !pendingChats.contains(where: { message == $0.key }) && !savedChats.contains(message)
//            }
//            Task {
            print(newValue)
            print("\n\n\n")
            Task {
                for message in newValue {
                    if !completedAndSavedChats.contains(where: { message.id == $0.id }) {
                        //                    if pendingChats.contains(where: { message.id == $0.key.id }) {
                        if let pendingChat = pendingChats.first(where: { message.id == $0.key.id }) {
                            if message.status == .completed {
                                // If not completed and pending and status is completed update and move to completedAndSavedChats
                                if let text = message.content.first(where: { $0.text != nil && !$0.text!.isEmpty })?.text { // TODO: Handle cases where multiple objects may be returned
                                    do {
                                        try await ChatCDHelper.updateChat(
                                            chat: pendingChat.value,
                                            text: text,
                                            in: viewContext)
                                        
                                        pendingChats.removeValue(forKey: message)
                                        
                                        completedAndSavedChats.append(message)
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error updating chat in LiveSpeechContainer... \(error)")
                                    }
                                }
                            }
                        } else {
                            if message.status == .in_progress || message.status == .incomplete {
                                // If not completed and not pending and status is in progress save and add to pendingChats
                                do {
                                    let sender = message.role == .user ? Sender.user : Sender.ai
                                    
                                    let chat = try await ChatCDHelper.appendChat(
                                        sender: sender,
                                        text: nil,
                                        to: conversation,
                                        in: viewContext)
                                    
                                    pendingChats[message] = chat
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error appending chat in LiveSpeechContainer... \(error)")
                                }
                            } else if message.status == .completed {
                                let text = message.content.first(where: { $0.text != nil && !$0.text!.isEmpty })?.text  // TODO: Handle cases where multiple objects may be returned
                                do {
                                    let sender = message.role == .user ? Sender.user : Sender.ai
                                    
                                    let chat = try await ChatCDHelper.appendChat(
                                        sender: sender,
                                        text: text,
                                        to: conversation,
                                        in: viewContext)
                                    
                                    // If not completed and not pending and status is completed and text is nil save and add to pendingChats
                                    if text == nil {
                                        pendingChats[message] = chat
                                    } else {
                                        // If not completed and not pending and status is completed and there is text save and add to pendingChats
                                        completedAndSavedChats.append(message)
                                    }
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error appending chat in LiveSpeechContainer... \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func onStopAll() {
        realtimeOpenAIConversation.stopHandlingVoice()
    }
    
    func onPausePlayActionButtonPressed() {
        if realtimeOpenAIConversation.handlingVoice {
            withAnimation {
                speakingBubbleState = .none
            }
            realtimeOpenAIConversation.stopHandlingVoice()
        } else {
            withAnimation {
                speakingBubbleState = .listeningAutoActive
            }
            do {
                try realtimeOpenAIConversation.startListening()
            } catch {
                // TODO: Handle Errors
                print("Error starting listening in LiveSpeechContainer... \(error)")
                return
            }
        }
    }
    
    func updateSession() {
        // If session is set by the server set it with preferences
        Task {
            // Get previous chats for context TODO: Make this better
            let previousChatsTranscriptsString: String = await getConversationChatsTranscriptString() ?? ""
            do {
                try await realtimeOpenAIConversation.setSession(
                    Session(
                        id: nil,
                        model: "gpt-4o-realtime-preview", // TODO: Put in enum
                        tools: [],
                        instructions: "Please speak in English unless instructed to do otherwise.\n\nHere are some transcripts from previous chats for context:\n\(previousChatsTranscriptsString)", // TODO: Better context
                        voice: constantsUpdater.liveSpeechVoice,
                        temperature: 1.0,
                        maxOutputTokens: nil,
                        toolChoice: .none,
                        turnDetection: Session.TurnDetection(
                            type: .serverVad,
                            threshold: 0.5,
                            prefixPaddingMs: 300,
                            silenceDurationMs: 500,
                            createResponse: true),
                        inputAudioFormat: .pcm16,
                        outputAudioFormat: .pcm16,
                        modalities: [.text, .audio],
                        inputAudioTranscription: Session.InputAudioTranscription(
                            model: "whisper-1" // TODO: Put in enum
                        )
                    )
                )
                
                try await MainActor.run {
                    try realtimeOpenAIConversation.startListening()
                }
            } catch {
                // TODO: Handle Errors
                print("Error setting realtime Open AI conversation session in LiveSpeechContainer... \(error)")
            }
        }
    }
    
    func getConversationChatsTranscriptString() async -> String? {
        // TODO: Fix this implementation to make it actually add chats in transcript.. this will cause it to potentially use new chats if the user updates the session.. also it's just bad lol
        let chatsFetchRequest = Chat.fetchRequest()
        chatsFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
        chatsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation)
        chatsFetchRequest.fetchLimit = 15
        do {
            return try await viewContext.perform { try viewContext.fetch(chatsFetchRequest) }.compactMap({ $0.text == nil ? nil : "\($0.sender ?? ""): \($0.text!)" }).joined(separator: "\n")
        } catch {
            // TODO: Handle Errors
            print("Error getting chats in LiveSpeechContainer... \(error)")
            return nil
        }
    }
    
//    func appendAndSaveAudioItem(audio: Item.Audio, message: Item.Message) {
//        if let transcript = audio.transcript {
//            // Append to savedChats
//            completedAndSavedChats.append(message)
//            
//            // Get sender
//            let sender = message.role == .user ? Sender.user : Sender.ai
//            
//            // Save to Conversation
//            do {
//                try ChatCDHelper.appendChat(
//                    sender: sender,
//                    text: transcript,
//                    to: conversation,
//                    in: viewContext)
//            } catch {
//                // TODO: Handle Errors
//                print("Error appending Chat in LiveSpeechContainer... \(error)")
//            }
//        }
//    }
    
    
    
}

//#Preview {
//    
//    let conversation = try! CDClient.mainManagedObjectContext.fetch(Conversation.fetchRequest())[0]
//    
//    return LiveSpeechContainer(
//        isPresented: .constant(true),
//        conversation: conversation,
//        persistentAttachments: FetchRequest(
//            sortDescriptors: [NSSortDescriptor(keyPath: \PersistentAttachment.date, ascending: false)],
//            predicate: NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation))
//    )
//    
//}
