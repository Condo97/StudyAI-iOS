//
//  FlashCardCollectionEditorTextField.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct FlashCardCollectionEditorTextField: View {
    
    var subheading: String
    var placeholder: LocalizedStringKey
    @Binding var text: String
    
    @FocusState private var focused
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $text)
                .focused($focused)
            Rectangle()
                .frame(height: focused ? 2 : 1)
                .opacity(focused ? 0.6 : 0.2)
                .animation(.bouncy(duration: 0.2), value: focused)
            Text(subheading)
                .font(.custom(Constants.FontName.body, size: 12.0))
                .opacity(focused ? 1.0 : 0.6)
                .animation(.bouncy(duration: 0.2), value: focused)
        }
    }
    
}

//#Preview {
//    
//    FlashCardCollectionEditorTextField(
//        subheading: "Subheading",
//        placeholder: "Placeholder",
//        text: .constant("")
//    )
//    
//}
