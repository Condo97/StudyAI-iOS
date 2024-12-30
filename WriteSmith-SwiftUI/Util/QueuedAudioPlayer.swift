//
//  QueuedAudioPlayer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/2/24.
//

import AVFoundation
import Combine

@MainActor
class QueuedAudioPlayer: AudioPlayer {
    
    @Published var isQueuePlaying: Bool = false
    
    private var audioQueue: [Data] = []
//    private var isQueuePlaying: Bool = false
    
    override init() {
        super.init()
    }
    
    func queue(data: Data) {
        audioQueue.append(data)
        if !isQueuePlaying {
            playNext()
        }
    }
    
    private func playNext() {
        guard !audioQueue.isEmpty else {
            isQueuePlaying = false
            return
        }
        
        let nextAudio = audioQueue.removeFirst()
        super.play(data: nextAudio)
        isQueuePlaying = true
    }
    
    override func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        super.audioPlayerDidFinishPlaying(player, successfully: flag)
        DispatchQueue.main.async {
            self.playNext()
        }
    }
    
    override func stop() {
        audioQueue.removeAll()
        isQueuePlaying = false
        super.stop()
    }
    
}
