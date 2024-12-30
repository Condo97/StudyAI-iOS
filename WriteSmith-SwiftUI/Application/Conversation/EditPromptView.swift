//
//  EditPromptView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/28/24.
//

import Foundation
import SwiftUI

struct EditPromptView: View {
    
    @Binding var editedPromptText: String
    var onClose: () -> Void
    var onSubmit: () -> Void
    
    
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 2.0) {
                    HStack {
                        Text("Edit Prompt")
                            .font(.custom(Constants.FontName.black, size: 17.0))
                            .foregroundStyle(Colors.textOnBackgroundColor)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Tell AI How to Behave...")
                            .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                            .foregroundStyle(Colors.textOnBackgroundColor)
                            .opacity(0.6)
                        
                        Spacer()
                    }
                }
                
                TextField("Tell AI How to Behave...", text: $editedPromptText, axis: .vertical)
                    .font(.custom(Constants.FontName.body, size: 14.0))
                    .lineLimit(5)
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                
                HStack {
                    Button(action: {
                        onClose()
                    }) {
                        Spacer()
                        Text("Close")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                            .foregroundStyle(Colors.text)
                        Spacer()
                    }
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                    Button(action: {
                        onSubmit()
                    }) {
                        Spacer()
                        Text("Save")
                            .font(.custom(Constants.FontName.black, size: 17.0))
                            .foregroundStyle(Colors.elementTextColor)
                        Spacer()
                    }
                    .padding()
                    .background(Colors.elementBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 280.0)
            .padding()
            .background(Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
    }
    
}
