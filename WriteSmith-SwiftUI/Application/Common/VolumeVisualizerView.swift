//
//  VolumeVisualizerView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/15/24.
//

import Foundation
import SwiftUI

struct VolumeVisualizerView: View {
    
    @Binding var meters: [Float]
    @State var barCount: Int
    @State var barSpacing: CGFloat
    @State var defaultZeroHeight: Float
    @State var heightMultiplier: Float
    
    
    var body: some View {
        ZStack {
            HStack(spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { i in
                    // Get currentMeter by an offset array to the end of meters, defaulting to defaultZeroHeight if meter is nil or negative
                    let currentMeter: Float = max(meters[safe: (meters.count - barCount + i)] ?? defaultZeroHeight, defaultZeroHeight)
                    
                    RoundedRectangle(cornerRadius: 14.0)
                        .frame(height: CGFloat(currentMeter * heightMultiplier))
                    
                }
            }
        }
    }
    
}


//#Preview {
//    
//    VolumeVisualizerView(
//        meters: .constant([0.4, 0.1, 0.5, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]),
//        barCount: 8,
//        barSpacing: 1.0,
//        defaultZeroHeight: 0.01,
//        heightMultiplier: 50.0
//    )
//    
//}
