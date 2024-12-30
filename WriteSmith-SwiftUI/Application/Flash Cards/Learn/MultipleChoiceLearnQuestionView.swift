//
//  MultipleChoiceLearnQuestionView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/20/24.
//

import SwiftUI

struct MultipleChoiceLearnQuestionView: View {
    
    var gameState: LearnController.GameState
    var multipleChoiceLearnQuestion: MultipleChoiceLearnQuestion
    @Binding var selectedAnswer: (any Equatable)?
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(multipleChoiceLearnQuestion.question)
                        .multilineTextAlignment(.leading)
                        .font(.custom(Constants.FontName.body, size: 20.0))
                        .foregroundStyle(Colors.text)
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                ForEach(multipleChoiceLearnQuestion.answers, id: \.self) { answer in
                    Button(action: {
                        withAnimation(.bouncy) {
                            selectedAnswer = answer
                        }
                    }) {
                        HStack {
                            Text(answer)
                                .font(.custom(Constants.FontName.body, size: 14.0))
                                .minimumScaleFactor(0.1)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .foregroundStyle(Colors.text)
                        .padding()
                        .background({
                            if gameState == .answerReveal {
                                if answer == multipleChoiceLearnQuestion.correctAnswer {
                                    return Color(.systemGreen)
                                } else if answer == selectedAnswer as? String {
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
    
    return MultipleChoiceLearnQuestionView(
        gameState: .quiz,
        multipleChoiceLearnQuestion: MultipleChoiceLearnQuestion(
            question: "Question",
            answers: [
                "Answer 1",
                "Answer 2",
                "Answer 3",
                "Answer 4"
            ],
            correctAnswerIndex: 3,
            flashCard: flashCard),
        selectedAnswer: $selectedAnswer)
    .frame(maxHeight: .infinity)
    .padding()
    .background(Colors.background)
    
}
