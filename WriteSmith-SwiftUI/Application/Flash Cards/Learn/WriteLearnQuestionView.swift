//
//  WriteLearnQuestionView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/20/24.
//

import SwiftUI

struct WriteLearnQuestionView: View {
    
    var gameState: LearnController.GameState
    var writeLearnQuestion: WriteLearnQuestion
    @Binding var selectedAnswer: (any Equatable)?
    
    @State private var writeLearnQuestionAnswerText: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(writeLearnQuestion.prompt)
                    .multilineTextAlignment(.leading)
                    .font(.custom(Constants.FontName.body, size: 20.0))
                Spacer()
            }
            
            TextField("Enter answer...", text: $writeLearnQuestionAnswerText)
                .font(.custom(Constants.FontName.body, size: 17.0))
                .foregroundStyle(Colors.text)
                .padding()
                .background({
                    if gameState == .answerReveal {
                        if writeLearnQuestionAnswerText == writeLearnQuestion.correctAnswer {
                            return Color(.systemGreen)
                        } else if true == selectedAnswer as? Bool {
                            return Color(.systemRed)
                        }
                    }
                    return Colors.foreground
                }())
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .opacity(gameState == .quiz ? 1.0 : 0.6)
            
            VStack {
                Button(action: {
                    withAnimation(.bouncy) {
                        selectedAnswer = writeLearnQuestionAnswerText
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Submit")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        Spacer()
                    }
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .opacity(gameState == .quiz ? 1.0 : 0.0)
            }
            
            Spacer()
        }
        .disabled(gameState != .quiz)
        .onChange(of: gameState) { newValue in
            if newValue == .quiz {
                // Reset writeLearnQustionAnswerText when GameState is set to quiz
                writeLearnQuestionAnswerText = ""
            }
        }
    }
    
}

@available(iOS 17.0, *)
#Preview {
    
    @Previewable @State var selectedAnswer: (any Equatable)?
    
    let flashCard: FlashCard = {
        if let flashCard = try? CDClient.mainManagedObjectContext.fetch(FlashCard.fetchRequest())[safe: 0] {
            return flashCard
        }
        
        let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
        flashCard.front = "Front"
        flashCard.back = "Back"
        
        return flashCard
    }()
    
    return WriteLearnQuestionView(
        gameState: .quiz,
        writeLearnQuestion: WriteLearnQuestion(
            prompt: "Write Prompt",
            correctAnswer: "Correct Answer",
            flashCard: flashCard),
        selectedAnswer: $selectedAnswer)
    .padding()
    .background(Colors.background)
    
}
