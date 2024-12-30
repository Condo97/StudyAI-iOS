//
//  ConversationFlashCardCollectionCreatorPopupButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct ConversationInitialActionButton: View {
    
    var title: LocalizedStringKey
    var subtitle: String?
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                
                VStack(alignment: .center) {
                    Text(title)
                        .font(.custom(Constants.FontName.body, size: 14.0))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom(Constants.FontName.body, size: 10.0))
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
//                Image(systemName: "chevron.right")
//                    .imageScale(.medium)
            }
            .foregroundStyle(Colors.text)
            .padding()
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
        }
    }
    
}

//#Preview {
//    
//    ConversationInitialActionButton(
//        title: "Title",
//        subtitle: "This is the subtitle",
//        action: {
//            
//        }
//    )
//    
//}
