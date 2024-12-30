//
//  LiveSpeechView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/24/24.
//

import SwiftUI

struct LiveSpeechView: View {
    
    enum PauseButtonState {
        case pause
        case play
        case stop
        case connecting
    }
    
    var pauseButtonState: PauseButtonState
    var audioLevels: [CGFloat]
    var assistant: Assistant?
    var attachment: PersistentAttachment?
    var speakingBubbleState: SpeakingBubbleStates
    var aiBubbleVolume: CGFloat
    var userBubbleVolume: CGFloat
//    @Binding var isUsingEarpiece: Bool
    var onStopAll: () -> Void
    var onPausePlayActionButtonPressed: () -> Void
    var onBeginManualListening: () -> Void
    var onEndManualListening: () -> Void
    var onDismiss: () -> Void
    
    enum SpeakingBubbleStates {
        case listeningAutoActive
        case listeningManualActive
        case listeningWaiting
        case speakingActive
        case speakingLoading
        case connecting
        case none
    }
    
    let minimizedSize: CGFloat = 50.0
    let maximizedSize: CGFloat = 250.0
    
    @State private var userBubblePulsatingAnimationScaleModifier: CGFloat = 1.0
    
    @State private var isDisplayingVoiceSelector: Bool = false
    
    private var instructionDisplayText: String {
        switch speakingBubbleState {
        case .listeningAutoActive:
            "Listening"
        case .listeningManualActive:
            "Release to send"
        case .listeningWaiting:
            "Start speaking"
        case .speakingActive:
            "Tap to interrupt"
        case .speakingLoading:
            "Tap to cancel"
        case .connecting:
            "Connecting..."
        case .none:
            "Tap to resume"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
//                // Voice Selector Button
//                Button("\(Image(systemName: "person.wave.2"))") {
//                    onStopAll()
//                    isDisplayingVoiceSelector = true
//                }
                
//                // Is Using Earpiece Button TODO: Make this another view or something so that it disables the touch screen so the user does not press buttons with their face
//                Button("\(Image(systemName: isUsingEarpiece ? "phone.badge.waveform" : "speaker.wave.3"))") {
//                    isUsingEarpiece.toggle()
//                }
//                .foregroundStyle(Colors.elementBackgroundColor)
                
//                // Silence Timer Button
//                Button(action: {
//                    // Increment silence timer
//                    switch ConstantsUpdater.liveSpeechSilenceDuration {
//                    case 6.0 : // 6 -> 0.5
//                        ConstantsUpdater.liveSpeechSilenceDuration = 0.5
//                    case 3.0: // 3 -> 6
//                        ConstantsUpdater.liveSpeechSilenceDuration = 6
//                    case 1.5: // 1.5 -> 3
//                        ConstantsUpdater.liveSpeechSilenceDuration = 3
//                    default: // ? -> 1.5, intended 0.5 -> 1.5
//                        ConstantsUpdater.liveSpeechSilenceDuration = 1.5
//                    }
//                }) {
//                    let numberFormatter: NumberFormatter = {
//                        let numberFormatter = NumberFormatter()
//                        numberFormatter.minimumFractionDigits = 0
//                        numberFormatter.maximumFractionDigits = 1
//                        numberFormatter.numberStyle = .decimal
//                        return numberFormatter
//                    }()
//                    HStack {
//                        Text("\(Image(systemName: "timer"))")
//                        Text("\(numberFormatter.string(from: NSNumber(value: ConstantsUpdater.liveSpeechSilenceDuration)) ?? "1.5")s")
//                        Spacer(minLength: 0.0)
//                    }
//                    .font(.custom(Constants.FontName.body, size: 14.0))
//                    .foregroundStyle(Colors.elementBackgroundColor)
//                    .frame(width: 58.0)
//                }
            }
            
            Spacer()
            
            VStack(spacing: speakingBubbleState == .none ? 16.0 : 32.0) {
                // AI Circle
                Circle()
                    .fill(Colors.aiChatBubbleColor)
                    .overlay {
                        AssistantOrAttachmentView(
                            assistant: assistant,
                            persistentAttachment: attachment)
                        .frame(width: speakingBubbleState == .speakingActive || speakingBubbleState == .speakingLoading ? maximizedSize / 4.0 : minimizedSize / 2.0)
                        .animation(.bouncy, value: speakingBubbleState)
                        .foregroundStyle(Colors.userChatTextColor)
                    }
                    .scaleEffect(1 + aiBubbleVolume * 2.0)
                    .frame(width: speakingBubbleState == .speakingActive || speakingBubbleState == .speakingLoading ? maximizedSize : minimizedSize)
                    .animation(.bouncy, value: speakingBubbleState)
                
                // User Circle
                Circle()
                    .fill(Colors.userChatBubbleColor)
                    .overlay {
                        if speakingBubbleState == .listeningManualActive {
                            ZStack {
                                Circle()
                                    .fill(Colors.background)
                                Circle()
                                    .stroke(Colors.userChatBubbleColor, lineWidth: 16.0)
                            }
                            .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        }
                    }
                    .overlay{
                        Image(systemName: "mic")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                            .frame(width: (speakingBubbleState == .listeningWaiting || speakingBubbleState == .listeningAutoActive || speakingBubbleState == .listeningManualActive) ? maximizedSize / 4.0 : speakingBubbleState == .none ? maximizedSize / 8.0 : minimizedSize / 2.0)
                            .foregroundStyle(speakingBubbleState == .listeningManualActive ? Colors.elementBackgroundColor : Colors.userChatTextColor)
                    }
                    .scaleEffect(1 * userBubblePulsatingAnimationScaleModifier + userBubbleVolume * 2.0)
                    .frame(width: (speakingBubbleState == .listeningWaiting || speakingBubbleState == .listeningAutoActive || speakingBubbleState == .listeningManualActive) ? maximizedSize : minimizedSize)
                    .animation(.bouncy, value: speakingBubbleState)
            }
            
            Spacer()
            
            // Display text
            VStack {
                Text(instructionDisplayText)
                    .font(.custom(Constants.FontName.body, size: 17.0))
                if speakingBubbleState == .listeningWaiting {
                    Text("Hold for manual control")
                        .font(.custom(Constants.FontName.body, size: 11.0))
                        .opacity(0.4)
                }
            }
            .padding(.bottom)
            
            // Pause and X Button
            HStack(alignment: .bottom) {
                Button(action: onPausePlayActionButtonPressed) {
                    ZStack {
                        if pauseButtonState == .connecting {
                            ProgressView()
                        } else {
                            Image(systemName: pauseButtonState == .pause ? "pause" : pauseButtonState == .play ? "play.fill" : "stop.fill")
                                .foregroundStyle(Colors.elementBackgroundColor)
                        }
                    }
//                        .padding()
                        .frame(width: 60.0, height: 60.0)
                        .background(Colors.elementTextColor)
                        .clipShape(Circle())
                }
                .disabled(pauseButtonState == .connecting)
                .opacity(pauseButtonState == .connecting ? 0.6 : 1.0)
                
                ZStack {
                    if speakingBubbleState == .listeningAutoActive || speakingBubbleState == .listeningManualActive || speakingBubbleState == .listeningWaiting {
                        MicrophoneVisualizerView(
                            isActive: speakingBubbleState == .listeningAutoActive || speakingBubbleState == .listeningManualActive || speakingBubbleState == .listeningWaiting, // TODO: Is this adequate
                            audioLevels: audioLevels)
                        .animation(.bouncy, value: speakingBubbleState)
                        .transition(.scale)
                    }
                }
                .frame(width: 140.0, height: 80.0)
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Colors.elementBackgroundColor)
//                        .padding()
                        .frame(width: 60.0, height: 60.0)
                        .background(Colors.elementTextColor)
                        .clipShape(Circle())
                }
            }
            .frame(height: 150.0)
        }
        .background(Colors.background)
        .gesture(
//            ExclusiveGesture(
                TapGesture()
                    .onEnded({ _ in
                        // Tapped, do the on pause play action
                        if speakingBubbleState != .connecting {
                            onPausePlayActionButtonPressed()
                        }
                    }))
//                SimultaneousGesture(
//                    LongPressGesture(minimumDuration: 0.5)
//                        .onEnded({ _ in
//                            // Long press started, begin manual listening
//                            onBeginManualListening()
//                        }),
//                    DragGesture(minimumDistance: 0.0)
//                        .onEnded({ _ in
//                            // Long press ended, end manual listening
//                            onEndManualListening()
//                        }))))
        .clearFullScreenCover(isPresented: $isDisplayingVoiceSelector) {
            VoiceSelectorContainer(isPresented: $isDisplayingVoiceSelector)
                .padding()
                .background(Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding()
        }
        .onChange(of: speakingBubbleState) { newValue in
            if newValue == .speakingLoading {
                startUserBubblePulsingAnimation()
            } else {
                stopUserBubblePulsingAnimation()
            }
        }
    }
    
    func startUserBubblePulsingAnimation() {
        withAnimation(.bouncy.repeatForever(autoreverses: true)) {
            userBubblePulsatingAnimationScaleModifier = 1.1
        }
    }
    
    func stopUserBubblePulsingAnimation() {
        withAnimation(.bouncy) {
            userBubblePulsatingAnimationScaleModifier = 1.0
        }
    }
    
}

//#Preview {
//    
//    LiveSpeechView(
//        pauseButtonState: .pause,
//        audioLevels: [0.0, 1.0, 5.0, 3.0, 6.0],
//        speakingBubbleState: .speakingLoading,
//        aiBubbleVolume: 0.0,
//        userBubbleVolume: 0.0,
//        isUsingEarpiece: .constant(false),
//        onStopAll: {
//            
//        },
//        onPausePlayActionButtonPressed: {
//            
//        },
//        onBeginManualListening: {
//            
//        },
//        onEndManualListening: {
//            
//        },
//        onDismiss: {
//            
//        })
//    
//}
