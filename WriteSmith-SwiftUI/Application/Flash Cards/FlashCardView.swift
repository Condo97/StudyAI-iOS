//
//  FlashCardView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/15/24.
//

import SwiftUI

struct FlashCardView: View {
    
    var front: String
    var back: String
    var fontSize: CGFloat
    
    @State private var isShowingBack: Bool = false
    @State private var rotation: Double = 0
    @State private var animationDuration: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Colors.foreground
            
            if isShowingBack {
                ZStack {
                    Text(back)
                        .font(.custom(Constants.FontName.body, size: fontSize))
                        .multilineTextAlignment(.center)
                        .padding(8)
                }
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 1, y: 0, z: 0)
                )
            } else {
                ZStack {
                    Text(front)
                        .font(.custom(Constants.FontName.medium, size: fontSize))
                        .multilineTextAlignment(.center)
                        .padding(8)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .aspectRatio(2, contentMode: .fit)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 1, y: 0, z: 0)
        )
        .onTapGesture {
            withAnimation(.bouncy(duration: animationDuration)) {
                rotation += 180
            }
            
            // Switch the text halfway through the flip
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration / 4.0 /* This number is because of the bouncy animation */) {
                isShowingBack.toggle()
            }
        }
    }
    
}

//#Preview {
//    
//    return FlashCardView(
//        front: "Front",
//        back: "Back",
//        fontSize: 14.0
//    )
//    .padding()
//    .background(Colors.background)
//    
//}
