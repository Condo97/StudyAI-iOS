//
//  PoweredByLearnMoreView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 5/17/24.
//

import SwiftUI

struct PoweredByLearnMoreView: View {
    
    @Binding var isPresented: Bool
    
    
    private enum ModelTabs {
        case gpt4Mini
        case gpt4o
        
        var name: String {
            switch self {
            case .gpt4Mini: "GPT-4 Mini"
            case .gpt4o: "GPT-4o + Vision"
            }
        }
        
        var description: LocalizedStringKey {
            switch self {
            case .gpt4Mini: "**The ultimate blend of speed and creativity.**\n\nUsed by 95% of AI apps, it provides fast answers with decent accuracy. While not the best for answering questions, it can think creatively to help you come up with new ideas.\n\nIf you find incorrect answers, try using GPT-4o + Vision which **passed the BAR** and 17 other exams."
            case .gpt4o: "**Upgrade your answers with doctorate-level intelligence.**\n\nGPT-4o, or GPT-4 Omni, has the ability to see images, listen to audio, search the web, and respond to text.\n\nTrained on over 1 Trillion words and updated for 2024, it is the **most capable AI** today."
            }
        }
    }
    
    @State private var selectedModelTab: ModelTabs = .gpt4o
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("AI Powered By...")
                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 0.0) {
                // Powered By Buttons
                HStack(spacing: 0.0) {
                    // GPT-4o Button
                    Button(action: {
                        selectedModelTab = .gpt4o
                    }) {
                        Text(ModelTabs.gpt4o.name)
                            .font(.custom(selectedModelTab == .gpt4o ? Constants.FontName.heavy : Constants.FontName.body, size: 14.0))
                            .foregroundStyle(selectedModelTab == .gpt4o ? Colors.elementBackgroundColor : Colors.elementTextColor)
                    }
                    .padding()
                    .background(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 14.0, topTrailing: 14.0))
                            .fill(selectedModelTab == .gpt4o ? Colors.foreground : Colors.elementBackgroundColor)
                    )
                    
                    // GPT-3.5 Turbo Button
                    Button(action: {
                        selectedModelTab = .gpt4Mini
                    }) {
                        Text(ModelTabs.gpt4Mini.name)
                            .font(.custom(selectedModelTab == .gpt4Mini ? Constants.FontName.heavy : Constants.FontName.body, size: 14.0))
                            .foregroundStyle(selectedModelTab == .gpt4Mini ? Colors.elementBackgroundColor : Colors.elementTextColor)
                    }
                    .padding()
                    .background(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 14.0, topTrailing: 14.0))
                            .fill(selectedModelTab == .gpt4Mini ? Colors.foreground : Colors.elementBackgroundColor)
                    )
                }
                
                // Information
                VStack {
                    HStack {
                        Text(selectedModelTab.description)
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        
                        Spacer()
                    }
                }
                .padding()
                .background(
                    UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(bottomLeading: 14.0, bottomTrailing: 14.0, topTrailing: 14.0))
                        .fill(Colors.foreground)
                )
            }
            
            // Close Button
            Button(action: {
                isPresented = false
            }) {
                HStack {
                    Spacer()
                    
                    Text("Close")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                        .foregroundStyle(Colors.elementTextColor)
                    
                    Spacer()
                }
                .padding()
                .background(Colors.buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        }
        .padding()
        .background(Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
}

//#Preview {
//    
//    ZStack {
//        
//    }
//    .clearFullScreenCover(isPresented: .constant(true)) {
//        PoweredByLearnMoreView(isPresented: .constant(true))
//            .padding()
//    }
//    
//}
