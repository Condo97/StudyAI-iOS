//
//  ModeSelectorView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/7/24.
//

import Foundation
import SwiftUI
import UIKit

struct ModeSelectorView: View {
    
    @Binding var selectedModeIndex: Int  // Starting with "Camera"
    let modes: [String] // ["Timelapse", "Video", "Camera", "Portrait", "Other"]

    @State private var viewLoaded: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            // Capture the screen center
            let screenCenter = geometry.size.width / 2

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0.0) {
                        ForEach(modes.indices, id: \.self) { index in
                            Text(modes[index])
                                .font(.custom(selectedModeIndex == index ? Constants.FontName.black : Constants.FontName.medium, size: selectedModeIndex == index ? 20.0 : 17.0))
                                .foregroundColor(.white)
                                .id(index)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ModeCenterXPreferenceKey.self, value: [index: geo.frame(in: .global).midX])
                                    }
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedModeIndex = index
                                        proxy.scrollTo(index, anchor: .center)
                                    }
                                }
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal, (geometry.size.width) / 2)
                    .onPreferenceChange(ModeCenterXPreferenceKey.self) { centers in
                        guard viewLoaded else { return }
                        // Update selected mode based on which Text is closest to center
                        let distances = centers.mapValues { abs($0 - screenCenter) }
                        if let minDistance = distances.values.min() {
                            let closestIndex = distances.first(where: { $0.value == minDistance })?.key
                            if let index = closestIndex, selectedModeIndex != index {
                                selectedModeIndex = index
                            }
                        }
                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onEnded { _ in
                                // Snap to the selected mode when scrolling ends
                                withAnimation {
                                    proxy.scrollTo(selectedModeIndex, anchor: .center)
                                }
                            }
                    )
                    .onAppear {
                        DispatchQueue.main.async {
                            // Ensure that the scrolling happens after the views have laid out
                            proxy.scrollTo(selectedModeIndex, anchor: .center)
                            viewLoaded = true
                        }
                    }
                }
            }
        }
    }
    
}

struct ModeCenterXPreferenceKey: PreferenceKey {
    
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        // Merge the new values with the existing ones
        value.merge(nextValue()) { (_, new) in new }
    }
    
}
