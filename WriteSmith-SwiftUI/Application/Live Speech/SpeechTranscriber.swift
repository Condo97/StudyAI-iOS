//
//  SpeechTranscriber.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/23/24.
//

import Foundation
import Speech

@MainActor
class SpeechTranscriber: ObservableObject {
    
    @Published var liveTranscribedText: String = ""
    @Published var finishedTranscribedText: String = ""
    @Published var isListening: Bool = false
    @Published var audioLevels: [CGFloat] = Array(repeating: 0.0, count: 4)
    @Published var errorMessage: String?
    @Published var isManualListeningEnabled: Bool = false
    @Published var isPaused: Bool = false
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var silenceTimer: Timer?
    
    private var silenceTimerDuration: Double {
        ConstantsUpdater.liveSpeechSilenceDuration
    }
    
    init() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized: break
                case .denied, .restricted, .notDetermined:
                    self.errorMessage = "Speech recognition authorization denied"
                @unknown default:
                    self.errorMessage = "Unknown speech recognition authorization status"
                }
            }
        }
    }
    
    func startListening() {
        // Ensure is not paused, otherwise set to false and return
        guard !isPaused else {
            isPaused = false
            return
        }
        
        // If speech transcriber has not been created start and create it
        if !audioEngine.isRunning {
            startAndCreateSpeechTranscriber()
        }
        
        // Create recognitionTask
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            if let result = result {
                // Update the transcribed text with the result
                self?.liveTranscribedText = result.bestTranscription.formattedString
                self?.resetSilenceTimer()
            }
            
            if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                self?.stopListening() // Handle errors by stopping listening
            }
        }
        
//        // If not isPaused reset finishedTranscribedText
//        if !isPaused {
            // Reset finishedTranscribedText
            finishedTranscribedText = ""
//        }
        
        // Set isListening to true
        isListening = true
        
//        // Set isPaused to false
//        isPaused = false
    }
    
    func stopListening() {
        DispatchQueue.main.async {
            // Ensure is listening, otherwise return
            guard self.isListening else {
                return
            }
            
            // Set isListening to false
            self.isListening = false
            
            // Capture the final transcription
            self.finishedTranscribedText = self.liveTranscribedText
            
            // Cancel and reset recognitionTask
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
        }
    }
    
    func pauseListening() {
        // Set isPaused to true
        isPaused = true
    }
    
    private func startAndCreateSpeechTranscriber() {
        guard speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer is not available. Please try again later."
            return
        }
        
        // Set isManualListeningEnabled to false
        isManualListeningEnabled = false
        
        // Reset finished text when starting a new listening session
        finishedTranscribedText = ""
        
        // Cancel the previous recognition task if it's running
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = true
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
//        let audioSession = AVAudioSession.sharedInstance()
        
        do {
//            try audioSession.setCategory(.record, mode: .measurement, options: []/*.duckOthers*/)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let inputNode = audioEngine.inputNode
            
            recognitionRequest?.shouldReportPartialResults = true
            
            
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
                DispatchQueue.main.async {
                    if self.isListening && !self.isPaused {
                        self.recognitionRequest?.append(buffer)
                        
                        //                // Calculate and publish audio volume
                        //                let volume = self.calculateVolume(from: buffer)
                        //                DispatchQueue.main.async {
                        //                    self.audioVolume = volume
                        //                }
                        
                        // Calculate and publish dynamic volume levels
                        if let tempAudioLevels = self.updateAudioLevels(from: buffer) {
                            self.audioLevels = tempAudioLevels
                        }
                    }
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            resetSilenceTimer()
        } catch {
            errorMessage = "Audio Engine couldn't start due to an error: \(error.localizedDescription)"
            stopAndDestroySpeechTranscriber()
        }
    }
    
    private func stopAndDestroySpeechTranscriber() {
        // Set isListening to false, stop audioEngine, remove tasks, and end recogntion request audio
        isListening = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        // Cancel the recognition task
        recognitionTask?.cancel() // This resets liveTranscribedText
        recognitionTask = nil
    }
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: ConstantsUpdater.liveSpeechSilenceDuration, repeats: false) { _ in
            DispatchQueue.main.async {
                self.stopRecordingIfSomeTextHasBeenTranscribed()
            }
        }
    }
    
    private func updateAudioLevels(from buffer: AVAudioPCMBuffer) -> [CGFloat]? {
        guard let channelData = buffer.floatChannelData else { return nil }
        
        var audioLevels: [CGFloat] = Array(repeating: 0.0, count: 4) // Four levels TODO: Make this dynamic

        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)
        let lowPassRange = 1000.0 // Low frequency up to 1000 Hz
        let midLowRange = 2000.0   // Mid-low frequency up to 2000 Hz
        let midHighRange = 3000.0  // Mid-high frequency up to 3000 Hz
        let highRange = 4000.0     // High frequency up to 4000 Hz

        var lowLevel: Float = 0.0
        var midLowLevel: Float = 0.0
        var midHighLevel: Float = 0.0
        var highLevel: Float = 0.0

        // Simple amplitude measurement
        for frame in 0..<frameLength {
            let sample = channelData[0][frame]

            // Categorize sample into frequency bands
            if frame < Int(lowPassRange) {
                lowLevel += abs(sample)
            } else if frame < Int(midLowRange) {
                midLowLevel += abs(sample)
            } else if frame < Int(midHighRange) {
                midHighLevel += abs(sample)
            } else if frame < Int(highRange) {
                highLevel += abs(sample)
            }
        }

        // Normalize and set levels
        let maxVolume = 80.0
        audioLevels[0] = max(min(CGFloat(lowLevel) / CGFloat(maxVolume), 1.0), 0.0)
        audioLevels[1] = max(min(CGFloat(midLowLevel) / CGFloat(maxVolume), 1.0), 0.0)
        audioLevels[2] = max(min(CGFloat(midHighLevel) / CGFloat(maxVolume), 1.0), 0.0)
        audioLevels[3] = max(min(CGFloat(highLevel) / CGFloat(maxVolume), 1.0), 0.0)
        
        return audioLevels
    }
    
    func stopRecordingIfSomeTextHasBeenTranscribed() {
        // Ensure some text has been transcribed, otherwise reset silence timer
        guard !liveTranscribedText.isEmpty else {
            resetSilenceTimer()
            return
        }
        
        // Ensure manual listening is not enabled, otherwise reset silence timer and return TODO: Should the silence timer continue to be reset or stopped here?
        guard !isManualListeningEnabled else {
            resetSilenceTimer()
            return
        }
        
        // Stop listening
        self.stopListening()
    }
    
    private func calculateVolume(from buffer: AVAudioPCMBuffer) -> CGFloat {
        guard let channelData = buffer.floatChannelData else { return 0.0 }
        
        let channelCount = Int(buffer.format.channelCount)
        let frameLength = Int(buffer.frameLength)

        var totalVolume: Float = 0.0
        for channel in 0..<channelCount {
            let channelDataArray = channelData[channel]
            // Calculate the sum of absolute values for the current channel
            let sum = (0..<frameLength).reduce(0.0) { $0 + abs(channelDataArray[$1]) }
            // Compute average power for current channel
            let avgPower = sum / Float(frameLength)
            totalVolume += avgPower
        }
        
        // Average over all channels
        return CGFloat(totalVolume / Float(channelCount))
    }
    
}
