//
//  LearnCompleteView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/26/24.
//

import SwiftUI

struct LearnCompleteView: View {
    
//    @Binding var learnController: LearnController? // This behavior is done in the container
    @Binding var learnedFlashCards: [FlashCard]?
    var onRestartLearn: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title and subtitle
//            Text("Congrats!")
//                .font(.custom(Constants.FontName.heavy, size: 17.0))
            Text("You've completed this session of learning.")
                .font(.custom(Constants.FontName.body, size: 17.0))
            
            // All terms
            if let learnedFlashCards = learnedFlashCards {
                ForEach(learnedFlashCards) { learnedFlashCard in
                    FlashCardLearnRoundCompleteTermView(flashCard: learnedFlashCard)
                        .padding()
                        .background(Colors.foreground)
                }
            } else {
                ProgressView()
            }
            
            Spacer()
            
            // Restart Learn button
            Button(action: onRestartLearn) {
                ZStack {
                    Text("Learn Again")
                    HStack {
                        Spacer()
                        Text("\(Image(systemName: "arrow.circlepath"))")
                    }
                }
                .font(.custom(Constants.FontName.body, size: 17.0))
                .foregroundStyle(Colors.elementTextColor)
                .padding()
                .background(Colors.elementBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        }
        .navigationTitle("Congrats!")
    }
    
}

#Preview {
    
    NavigationStack {
        LearnCompleteView(
            learnedFlashCards: .constant(nil),
            onRestartLearn: {
                
            }
        )
        .padding()
        .background(Colors.background)
    }
    
}
