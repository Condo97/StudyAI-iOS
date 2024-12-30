//
//  TrueFalseLearnQuestionView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/20/24.
//

import SwiftUI

struct TrueFalseLearnQuestionView: View {
    
    var gameState: LearnController.GameState
    var trueFalseLearnQuestion: TrueFalseLearnQuestion
    @Binding var selectedAnswer: (any Equatable)?
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                Text(trueFalseLearnQuestion.flashCardStatement)
                    .font(.custom(Constants.FontName.light, size: 20.0))
                    .foregroundStyle(Colors.text)
                Divider()
                    .frame(maxWidth: 150.0)
                Text(trueFalseLearnQuestion.proposedMatchingStatement)
                    .font(.custom(Constants.FontName.medium, size: 20.0))
                    .foregroundStyle(Colors.text)
                Spacer()
            }
            .padding(.bottom)
            
            VStack {
                Button(action: {
                    withAnimation(.bouncy) {
                        selectedAnswer = true
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("True")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        Spacer()
                    }
                    .foregroundStyle(Colors.text)
                    .padding()
                    .background({
                        if gameState == .answerReveal {
                            if true == trueFalseLearnQuestion.correctAnswer {
                                return Color(.systemGreen)
                            } else if true == selectedAnswer as? Bool {
                                return Color(.systemRed)
                            }
                        }
                        return Colors.foreground
                    }())
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .opacity(gameState == .quiz ? 1.0 : 0.6)
                
                Button(action: {
                    withAnimation(.bouncy) {
                        selectedAnswer = false
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("False")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        Spacer()
                    }
                    .foregroundStyle(Colors.text)
                    .padding()
                    .background({
                        if gameState == .answerReveal {
                            if false == trueFalseLearnQuestion.correctAnswer {
                                return Color(.systemGreen)
                            } else if false == selectedAnswer as? Bool {
                                return Color(.systemRed)
                            }
                        }
                        return Colors.foreground
                    }())
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .opacity(gameState == .quiz ? 1.0 : 0.6)
            }
        }
        .disabled(gameState != .quiz)
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
    
    return TrueFalseLearnQuestionView(
        gameState: .quiz,
        trueFalseLearnQuestion: TrueFalseLearnQuestion(
            flashCardStatement: "Flash Card Statement",
            proposedMatchingStatement: "Proposed Matching Statement",
            correctAnswer: true,
            flashCard: flashCard),
        selectedAnswer: $selectedAnswer)
    .padding()
    .background(Colors.background)
    
}
