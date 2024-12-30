//
//  MicrophoneVisualizerView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/2/24.
//

import SwiftUI

struct MicrophoneVisualizerView: View {
    
//    @ObservedObject var speechTranscriber = SpeechTranscriber()
    var isActive: Bool
    var audioLevels: [CGFloat]

    var body: some View {
        HStack(alignment: .bottom, spacing: 4.0) {
            Image(systemName: "mic")
                .foregroundStyle(Colors.userChatBubbleColor)
            
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 4.0) {
                    ForEach(0..<audioLevels.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 14.0)
                            .fill(Colors.userChatBubbleColor)
                            .frame(height: isActive ? ((geometry.size.height * audioLevels[index]) * 1.0 + 20) : 1.0)
                        //                        .frame(width: 14.0, height: audioLevels[index] * 3) // Scale height
                            .animation(.bouncy(duration: 0.1), value: audioLevels[index]) // Smooth transition
                    }
                }
                .frame(height: geometry.size.height, alignment: .bottom)
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
    
}

//#Preview {
//    
//    MicrophoneVisualizerView(
//        isActive: true,
//        audioLevels: [0.0, 1.0, 0.5, 0.3])
//    
//}
