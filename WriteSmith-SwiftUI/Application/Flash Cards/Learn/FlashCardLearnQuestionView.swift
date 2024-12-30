//
//  FlashCardLearnQuestionView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/19/24.
//

import SwiftUI

struct FlashCardLearnQuestionView: View {
    
    @ObservedObject var learnController: LearnController
    
//    @State private var writeLearnQuestionAnswerTextFieldTextToBeMoved: String = ""
    
    var body: some View {
        if let multipleChoiceLearnQuestion = learnController.currentQuestion as? MultipleChoiceLearnQuestion {
            MultipleChoiceLearnQuestionView(
                gameState: learnController.gameState,
                multipleChoiceLearnQuestion: multipleChoiceLearnQuestion,
                selectedAnswer: $learnController.userSelectedAnswer)
        } else if let trueFalseLearnQuestion = learnController.currentQuestion as? TrueFalseLearnQuestion {
            TrueFalseLearnQuestionView(
                gameState: learnController.gameState,
                trueFalseLearnQuestion: trueFalseLearnQuestion,
                selectedAnswer: $learnController.userSelectedAnswer)
        } else if let writeLearnQuestion = learnController.currentQuestion as? WriteLearnQuestion {
            WriteLearnQuestionView(
                gameState: learnController.gameState,
                writeLearnQuestion: writeLearnQuestion,
                selectedAnswer: $learnController.userSelectedAnswer)
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
            FlashCardLearnQuestionView(learnController: learnController)
                .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        } else {
            VStack {
                
            }
            .task {
                learnController = await LearnController(
                    results: learnQuestionResultCollection,
                    maxQuestionCount: 20,
                    amountOverMinimumCorrectToConsiderLearned: 2,
                    questionTypeRatios: [.multipleChoice: 1.0, .trueFalse: 0.0, .write: 0.0],
                    frontIsQuestion: true,
                    managedObjectContext: CDClient.mainManagedObjectContext)
            }
        }
    }
    
}
