//
//  FlashCardLearnRoundCompleteTermView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/22/24.
//

import SwiftUI

struct FlashCardLearnRoundCompleteTermView: View {
    
//    var learnQuestion: any LearnQuestion
    var flashCard: FlashCard
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Term
                Text(flashCard.front ?? "Term")
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                
                Spacer()
                
                // TODO: Speak
                
                // TODO: Star, also learn the functionality probably like a favorite to keep it in mind and review it or something
            }
            
            // Definition
            Text(flashCard.back ?? "Definition")
                .font(.custom(Constants.FontName.body, size: 17.0))
        }
    }
    
}

//#Preview {
//    
//    FlashCardLearnRoundCompleteTermView()
//    
//}
