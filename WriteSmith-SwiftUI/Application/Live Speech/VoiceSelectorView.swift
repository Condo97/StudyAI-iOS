//
//  VoiceSelectorView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/5/24.
//

import SwiftUI
import OpenAI

struct VoiceSelectorView: View {
    
    @Binding var liveSpeechVoice: Session.Voice
//    @Binding var speed: Double
    
//    @StateObject private var liveSpeechAudioSessionUpdater: LiveSpeechAudioSessionUpdater = LiveSpeechAudioSessionUpdater() // TODO: This should always be the speaker right or maybe not maybe it should be this hm think about this
//    @StateObject private var queuedAudioPlayer: QueuedAudioPlayer = QueuedAudioPlayer()
    
    @State private var isLoadingTryVoice: Bool = false
    
    private let tryVoiceTranscripts: [String] = [
        "Why did the math book look sad? It had too many problems.",
        "Science class is where I learned the hard way that mixing soda and vinegar is a bad idea.",
        "History teachers like to say, 'Those who don’t study history are doomed to retake the test!'",
        "Gym class is where I discovered my true talent: dodging flying basketballs.",
        "Why do plants hate math? Because it gives them square roots!",
        "The best part of school lunch? Trading my carrots for cookies.",
        "Did you hear about the claustrophobic astronaut? He just needed a little space during recess.",
        "Homework is like a bad joke; no one wants to hear it, but we all have to deal with it.",
        "Art class is the only time throwing paint can be considered productive.",
        "Why was the teacher wearing sunglasses? Because her students were so bright!",
        "P.E. stands for 'Please Endure' when it’s time for the mile run.",
        "My backpack is like a black hole; things just disappear in there.",
        "Did you know pencils have feelings? They’re always drawn to each other.",
        "Geography class taught me that I can't find my way out of the library.",
        "In English class, I learned that a thesaurus is my best friend after the word \"fun\" runs out.",
        "Biology class proved that even cells know how to divide.",
        "Why don’t scientists trust atoms? Because they make up everything... including our grades!",
        "School is like a buffet; everyone’s just trying to get a taste of the fun!",
        "We should hire a motivational speaker for the cafeteria; lunch isn’t that fishy!",
        "My favorite subject is lunch; it never fails to deliver a slice of fun!",
        "If laughter is the best medicine, then recess is the school’s pharmacy!"
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text("Select Voice")
                .font(.custom(Constants.FontName.medium, size: 20.0))
            
            // Voices
            SingleAxisGeometryReader(axis: .horizontal) { geo in
                FlexibleView(
                    availableWidth: geo.magnitude,
                    data: Session.Voice.allCases,
                    spacing: 8.0,
                    alignment: .leading,
                    content: { speechVoice in
                        Button(action: {
                            liveSpeechVoice = speechVoice
                        }) {
                            Text(speechVoice.rawValue)
                                .font(.custom(liveSpeechVoice == speechVoice ? Constants.FontName.heavy : Constants.FontName.medium, size: 17.0))
                                .foregroundStyle(liveSpeechVoice == speechVoice ? Colors.userChatTextColor : Colors.userChatBubbleColor)
                                .padding()
                                .background(liveSpeechVoice == speechVoice ? Colors.userChatBubbleColor : Colors.userChatTextColor)
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        }
                    })
            }
            
//            // Speech Test
//            Button(action: {
//                Task {
//                    // Defer setting isLoadingTryVoice to false
//                    defer {
//                        DispatchQueue.main.async {
//                            self.isLoadingTryVoice = false
//                        }
//                    }
//                    
//                    // Set isLoadingTryVoice to true
//                    await MainActor.run {
//                        isLoadingTryVoice = true
//                    }
//                    
//                    // Ensure authToken
//                    let authToken: String
//                    do {
//                        authToken = try await AuthHelper.ensure()
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error ensuring authToken in LiveSpeechContainer... \(error)")
//                        return
//                    }
//                    
//                    // Generate speech
//                    let speech: Data
//                    do {
//                        speech = try await SpeechGenerator.generateSpeech(
//                            authToken: authToken,
//                            input: tryVoiceTranscripts.randomElement() ?? "Hi I'm your new AI.",
//                            speed: speed,
//                            voice: liveSpeechVoice)
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error generating speech in VoiceSelectorView... \(error)")
//                        return
//                    }
//                    
//                    // Speak
//                    queuedAudioPlayer.queue(data: speech)
//                }
//            }) {
//                HStack {
//                    Text("Try Voice \(Image(systemName: "speaker.wave.3"))")
//                    if queuedAudioPlayer.isQueuePlaying {
//                        ProgressView()
//                    }
//                }
//            }
//            .disabled(queuedAudioPlayer.isQueuePlaying || isLoadingTryVoice)
//            .foregroundStyle(Colors.userChatBubbleColor)
//            .padding(.vertical)
            
//            Text("Speed")
//                .font(.custom(Constants.FontName.medium, size: 20.0))
//            
//            Picker("", selection: $speed) {
//                Text("0.5x")
//                    .tag(0.5)
//                Text("1.0x")
//                    .tag(1.0)
//                Text("1.25x")
//                    .tag(1.25)
//                Text("1.5x")
//                    .tag(1.5)
//                Text("2.0x")
//                    .tag(2.0)
//            }
//            .pickerStyle(.segmented)
        }
    }
    
}

#Preview {
    
    VoiceSelectorView(
        liveSpeechVoice: .constant(.alloy))
//        speed: .constant(1.0))
        .padding()
        .background(Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    
}
