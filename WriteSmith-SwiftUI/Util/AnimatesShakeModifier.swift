//
//  AnimatesShakeModifier.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/5/24.
//

import Foundation
import SwiftUI

struct AnimatesShakeModifier: ViewModifier {
    
    @Binding var isMoving: Bool
    @State var maxAngle: Angle
    @State var speed: CGFloat
    
    @State private var currentAngle: Angle = .zero
    
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(isMoving ? currentAngle : .zero)
            .onAppear {
                // If set to isPulsating on appear
                if isMoving {
                    startMoving()
                }
            }
            .onChange(of: isMoving) { newValue in
                // If set to isPulsating after appear
                if newValue {
                    startMoving()
                }
            }
    }
    
    func startMoving() {
        currentAngle = -maxAngle
        
        withAnimation(.linear(duration: speed).repeatForever(autoreverses: true)) {
            currentAngle = maxAngle
        }
    }
    
}

extension View {
    
    func animatesShake(isMoving: Binding<Bool>, maxAngle: Angle, speed: CGFloat) -> some View {
        modifier(AnimatesShakeModifier(
            isMoving: isMoving,
            maxAngle: maxAngle,
            speed: speed))
    }
    
}


//#Preview {
//    
//    ZStack {
//        Text("Hi")
//            .modifier(
//                AnimatesShakeModifier(
//                    isMoving: .constant(true),
//                    maxAngle: .degrees(28),
//                    speed: 1)
//            )
//    }
//    
//}
//
