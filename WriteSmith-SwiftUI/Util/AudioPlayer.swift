//
//  AudioPlayer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/23/24.
//

import AVFoundation
import Combine

@MainActor
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    private var player: AVAudioPlayer?
    private var volumeTimer: Timer?
    
    @Published var isPlaying: Bool = false
    @Published var isFinishedPlaying: Bool = false
    @Published var audioVolume: CGFloat = 0.0 // Volume to scale the bubble
    
    var duration: TimeInterval {
        return player?.duration ?? 0
    }
    
    override init() {
        super.init()
//        configureAudioSession()
        player?.delegate = self
    }
    
    func play(data: Data) {
//        DispatchQueue.main.async {
            do {
                self.player = try AVAudioPlayer(data: data)
                self.player?.delegate = self
                self.player?.play()
                self.player?.isMeteringEnabled = true
                self.isPlaying = true
                self.isFinishedPlaying = false
                
                // Start a timer to update audio volume
                self.volumeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    DispatchQueue.main.async {
                        self.updateVolume()
                    }
                }
                
//                // Schedule for non-blocking play state
//                DispatchQueue.global().async {
//                    while self.isPlaying {
//                        // Keep the state updated
//                        Thread.sleep(forTimeInterval: 0.1)
//                    }
//                    
//                    self.volumeTimer?.invalidate()
//                }
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
//        }
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    // AVAudioPlayerDelegate method
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isFinishedPlaying = true
            // Additional action can be taken here if needed
        }
    }
    
//    private func configureAudioSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
//            try audioSession.setActive(true)
//        } catch {
//            print("Failed to set up audio session: \(error.localizedDescription)")
//        }
//    }
    
    private func updateVolume() {
        guard let player = player else { return }
        // Get the average power (in dB) for channel 0
        player.updateMeters()
        let averagePower = player.averagePower(forChannel: 0)
        
        // Convert the average power from dB to a scale from 0 to 1
        // Depending on your needs, you might want to adjust the scaling factor
        audioVolume = CGFloat((averagePower + 80) / 80) // Assuming power range from -80 dB to 0 dB
        audioVolume = min(max(audioVolume, 0), 1) // Clamp the value between 0 and 1
    }
    
}
