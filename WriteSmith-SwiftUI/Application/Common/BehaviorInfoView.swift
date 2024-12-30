//
//  BehaviorInfoView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/20/24.
//

import SwiftUI

struct BehaviorInfoView: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            Text("Behavior")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
            
            Text("Tell AI how to act. Try setting education level or topic.")
                .font(.custom(Constants.FontName.body, size: 17.0))
            
            VStack(alignment: .leading) {
                Text("• \"Act as a college history professor\"")
                Text("• \"You are a Chemist with a PHD and know it all")
                Text("• \"Be a cute AI and use emojis\"")
            }
            .font(.custom(Constants.FontName.body, size: 12.0))
            
            Button(action: {
                isPresented = false
            }) {
                HStack {
                    Spacer()
                    Text("Close")
                        .font(.custom(Constants.FontName.body, size: 17.0))
                    Spacer()
                }
                .foregroundStyle(Colors.elementBackgroundColor)
                .padding()
                .background(Colors.foreground)
            }
        }
    }
    
}

//#Preview {
//    
//    ZStack {
//        
//    }
//    .clearFullScreenCover(isPresented: .constant(true)) {
//        BehaviorInfoView(isPresented: .constant(true))
//            .padding()
//            .background(Colors.background)
//            .clipShape(RoundedRectangle(cornerRadius: 14.0))
//            .padding()
//    }
//    
//}
