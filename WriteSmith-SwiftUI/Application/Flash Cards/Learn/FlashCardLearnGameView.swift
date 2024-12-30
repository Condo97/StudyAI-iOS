//
//  FlashCardLearnGameView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/19/24.
//

import SwiftUI

// TODO: If recently wrong, show "let's try again," and when it is correct remove the mark
// TODO: Also maybe make the query more reactive because it sets the problems to recently wrong

struct FlashCardLearnGameView: View {
    
    @ObservedObject var learnController: LearnController
    
    var body: some View {
        VStack {
            FlashCardLearnQuestionView(learnController: learnController)
                .padding(.vertical)
            
            if learnController.gameState == .answerReveal {
                Button(action: {
                    learnController.nextQuestion()
                }) {
                    HStack {
                        Spacer()
                        Text("Next")
                            .font(.custom(Constants.FontName.heavy, size: 20.0))
                        Spacer()
                    }
                    .foregroundStyle(Colors.elementTextColor)
                    .padding()
                    .background(Colors.elementBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
        }
    }
    
}

@available(iOS 17.0, *)
#Preview {
    
    @Previewable @State var learnController: LearnController?
    
    let learnQuestionResultCollection = {
        let learnQuestionResultCollection = LearnQuestionResultCollection(context: CDClient.mainManagedObjectContext)
        learnQuestionResultCollection.flashCardCollection = FlashCardCollection(context: CDClient.mainManagedObjectContext)
        
        learnQuestionResultCollection.flashCardCollection?.addToFlashCards({
            let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
            flashCard.front = "Front1"
            flashCard.back = "Back1"
            return flashCard
        }())
        
        learnQuestionResultCollection.flashCardCollection?.addToFlashCards({
            let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
            flashCard.front = "Front2"
            flashCard.back = "Back2"
            return flashCard
        }())
        
        learnQuestionResultCollection.flashCardCollection?.addToFlashCards({
            let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
            flashCard.front = "Front3"
            flashCard.back = "Back3"
            return flashCard
        }())
        
        return learnQuestionResultCollection
    }()
    
    return VStack {
        if let learnController = learnController {
            NavigationStack {
                FlashCardLearnGameView(
                    learnController: learnController)
                    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
                    .background(Colors.background)
            }
        } else {
            VStack {
                
            }
            .task {
                learnController = await LearnController(
                    results: learnQuestionResultCollection,
                    maxQuestionCount: 20,
                    amountOverMinimumCorrectToConsiderLearned: 2,
                    questionTypeRatios: [.multipleChoice: 0.8, .trueFalse: 0.1, .write: 0.1],
                    frontIsQuestion: true,
                    managedObjectContext: CDClient.mainManagedObjectContext)
            }
        }
    }
    
}
