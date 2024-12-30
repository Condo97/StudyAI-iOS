//
//  FlashCardLearnSetupStudyStyleButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/26/24.
//

import SwiftUI

struct FlashCardLearnSetupStudyStyleButton<Content: View>: View {
    
    var title: String
    var subtitle: String
    var detailDisclosure: Content
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                    Text(subtitle)
                        .font(.custom(Constants.FontName.body, size: 17.0))
                }
                
                Spacer()
                
//                Text("\(image)")
                detailDisclosure
                    .font(.custom(Constants.FontName.body, size: 17.0))
                    
            }
            .padding()
        }
    }
    
}

#Preview {
    
    ZStack {
        FlashCardLearnSetupStudyStyleButton(
            title: "Title",
            subtitle: "This is the subtitle",
            detailDisclosure: Image(systemName: "clock"),
            action: {
                
            })
    }
    
}
