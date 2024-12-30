//
//  Draggable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct Draggable: ViewModifier {
    
    @Binding var isOpen: Bool  // Binding to track open/closed state
    var revealWidth: CGFloat = 250.0       // Adjust this width as per the required reveal amount
    
    @State private var xOffset: CGFloat = 0.0
    private let velocityThreshold: CGFloat = 500.0  // Adjust based on desired responsiveness for flicks
    
    func body(content: Content) -> some View {
        content
            .offset(x: xOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let totalSlide = gesture.translation.width
                        // Set xOffset only if moving left, otherwise maintain current state
                        xOffset = min(totalSlide + (isOpen ? -revealWidth : 0), 0)
                    }
                    .onEnded { gesture in
                        withAnimation {
                            let totalSlide = xOffset
                            let velocity = gesture.velocity.width
                            
                            if totalSlide < -revealWidth / 2 || abs(velocity) > velocityThreshold {
                                // Open the card if the swipe was fast or dragged more than half the reveal width
                                xOffset = -revealWidth
                                isOpen = true  // Update the binding to reflect open state
                            } else {
                                // Close the card if the swipe didn't meet the criteria
                                xOffset = 0
                                isOpen = false  // Update the binding to reflect closed state
                            }
                        }
                    }
            )
            .onAppear {
                // Ensure the initial offset reflects the open/closed state when the view appears
                xOffset = isOpen ? -revealWidth : 0
            }
            .onChange(of: isOpen) { newValue in
                // If isOpen is changed set to -revealWidth if true or 0 if false
                withAnimation(.bouncy(duration: 0.5)) {
                    xOffset = newValue ? -revealWidth : 0
                }
            }
    }
    
}


extension View {
    
    func draggable(isOpen: Binding<Bool>, revealWidth: CGFloat = 250.0) -> some View {
        self
            .modifier(Draggable(
                isOpen: isOpen,
                revealWidth: revealWidth))
    }
    
}


//#Preview {
//
//    Draggable()
//    
//}
