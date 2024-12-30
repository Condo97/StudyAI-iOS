//
//  AnimatesPulsateModifier.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/5/24.
//

import Foundation
import SwiftUI

struct AnimatesPulsateModifier: ViewModifier {
    
    @Binding var isPulsating: Bool
    @State var minScale: CGSize
    @State var maxScale: CGSize
    @State var speed: CGFloat
    
    fileprivate static let oneScale: CGSize = CGSize(width: 1.0, height: 1.0)
    @State private var currentScale: CGSize = oneScale
    
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsating ? currentScale : AnimatesPulsateModifier.oneScale)
//            .animation(.linear(duration: speed).repeatForever(autoreverses: true), value: currentScale)
            .onAppear {
                // If set to isPulsating on appear
                if isPulsating {
                    startPulsating()
                }
            }
            .onChange(of: isPulsating) { newValue in
                // If set to isPulsating after appear
                if newValue {
                    startPulsating()
                }
            }
    }
    
    func startPulsating() {
        currentScale = minScale
        
        withAnimation(.linear(duration: speed).repeatForever(autoreverses: true)) {
            currentScale = maxScale
        }
    }
    
}

extension View {
    
    func animatesPulsate(isPulsating: Binding<Bool>, minScale: CGSize = AnimatesPulsateModifier.oneScale, maxScale: CGSize, speed: CGFloat) -> some View {
        modifier(AnimatesPulsateModifier(
            isPulsating: isPulsating,
            minScale: minScale,
            maxScale: maxScale,
            speed: speed))
    }
    
}


//#Preview {
//    
//    ZStack {
//        Text("Hi")
//            .animatesPulsate(
//                isPulsating: .constant(true),
//                minScale: CGSize(width: 0.1, height: 0.1),
//                maxScale: CGSize(width: 2.0, height: 2.0),
//                speed: 1.0)
//    }
//    
//}
