//
//  VoiceSelectorContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/5/24.
//

import OpenAI
import SwiftUI

struct VoiceSelectorContainer: View {
    
    @Binding var isPresented: Bool
    
    @EnvironmentObject private var constantsUpdater: ConstantsUpdater
    
//    @State private var liveSpeechSpeed: Double = ConstantsUpdater.liveSpeechSpeed
//    @State private var liveSpeechVoice: Session.Voice = constantsUpdater.liveSpeechVoice
    
    var body: some View {
        VStack {
            VoiceSelectorView(
                liveSpeechVoice: $constantsUpdater.liveSpeechVoice)
//                speed: $liveSpeechSpeed)
            
            HStack {
//                // Close Button
//                Button(action: {
//                    // Close
//                    isPresented = false
//                }) {
//                    Text("Close")
//                        .font(.custom(Constants.FontName.body, size: 17.0))
//                        .foregroundStyle(Colors.elementBackgroundColor)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Colors.elementTextColor)
//                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                }
//                
                // Save Button
                Button(action: {
                    // Save and close
//                    constantsUpdater.liveSpeechSpeed = liveSpeechSpeed
//                    constantsUpdater.liveSpeechVoice = liveSpeechVoice
                    isPresented = false
                }) {
                    Text("Save")
                        .font(.custom(Constants.FontName.medium, size: 17.0))
                        .foregroundStyle(Colors.elementTextColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Colors.elementBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
        }
    }
    
}

#Preview {
    
    VoiceSelectorContainer(
        isPresented: .constant(true))
    .environmentObject(ConstantsUpdater())
    
}
