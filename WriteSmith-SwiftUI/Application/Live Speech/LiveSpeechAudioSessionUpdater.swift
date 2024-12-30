//
//  LiveSpeechAudioSessionUpdater.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/4/24.
//

import AVKit
import Combine
import Foundation
import SwiftUI

class LiveSpeechAudioSessionUpdater: ObservableObject {
    
    @Published var isUsingEarpiece: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        // Create sink to switch audio route on update of isUsingEarpiece
        $isUsingEarpiece.sink(receiveValue: switchAudioRoute)
            .store(in: &cancellables) // Used to maintain a strong reference to the subscription so that values are updated
        
        // Switch audio route to initial value of isUsingEarpiece
        switchAudioRoute(toEarpiece: isUsingEarpiece)
        
        // Set audioSession to active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // TODO: Handle Errors
            print("Error setting AVAudioSession instance to active in LiveSpeechAudioSessionUpdater... \(error)")
        }
    }
    
    private func switchAudioRoute(toEarpiece: Bool) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if toEarpiece {
                try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [])
//                try audioSession.overrideOutputAudioPort(.none)
            } else {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
//                try audioSession.overrideOutputAudioPort(.speaker)
            }
        } catch {
            // TODO: Handle Errors
            print("Error overriding output audio port for audio session in LiveSpeechContainer... \(error)")
        }
    }
    
}
