//
//  WaveformLineUIViewRepresentable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/15/24.
//

import AVKit
import DSWaveformImageViews
import Foundation
import SwiftUI
import UIKit

struct WaveformLiveUIViewRepresentable: UIViewRepresentable {
    
    @Binding var meter: Float
    
    func makeUIView(context: Context) -> WaveformLiveView {
        let waveformView = WaveformLiveView()
        return waveformView
    }
    
    func updateUIView(_ uiView: WaveformLiveView, context: Context) {
//        guard let audioRecorder = audioRecorder else { return }
//        guard audioRecorder.isRecording else { return }
//        audioRecorder.updateMeters()
//        let currentAmplitude = 1 - pow(10, audioRecorder.averagePower(forChannel: 0) / 20)
        uiView.add(sample: meter)
    }
    
}
