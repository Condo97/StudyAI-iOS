//
//  FlashCardCollectionCreatorPromptEntryView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/18/24.
//

import SwiftUI

struct FlashCardCollectionCreatorPromptEntryView: View {
    
    @Binding var isPresented: Bool
    var onSubmit: (_ promptText: String) -> Void
    
    @FocusState private var promptTextFieldFocused
    
    @State private var promptText: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Enter Prompt")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
            Text("Instruct AI to make flash cards for any topic. Provide as many details as possible.")
                .font(.custom(Constants.FontName.body, size: 14.0))
            
            TextEditor(text: $promptText)
//            TextField("Enter Prompt", text: $promptText, axis: .vertical)
                .focused($promptTextFieldFocused)
                .overlay(alignment: .topLeading) {
                    if promptText.isEmpty && !promptTextFieldFocused {
                        Text("Tap to Enter Prompt...")
                            .opacity(0.4)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 150.0)
                .padding()
                .scrollContentBackground(.hidden)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .font(.custom(Constants.FontName.body, size: 17.0)) // This propagates to the overlay too!
            
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(Colors.elementBackgroundColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Colors.elementTextColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                
                Button(action: {
                    onSubmit(promptText)
                    isPresented = false
                }) {
                    Text("Submit")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .foregroundStyle(Colors.elementTextColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Colors.elementBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
        }
        .background(Colors.background)
    }
    
}

//#Preview {
//    
//    FlashCardCollectionCreatorPromptEntryView(
//        isPresented: .constant(true),
//        onSubmit: { promptText in
//        
//    })
//    
//}
