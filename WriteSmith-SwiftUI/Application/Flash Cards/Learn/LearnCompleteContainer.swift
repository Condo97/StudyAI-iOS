//
//  LearnCompleteContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/26/24.
//

import SwiftUI

struct LearnCompleteContainer: View {
    
    @Binding var learnController: LearnController?
    
    @State private var learnedFlashCards: [FlashCard]?
    
    var body: some View {
        LearnCompleteView(
            learnedFlashCards: $learnedFlashCards,
            onRestartLearn: {
                learnController = nil
        })
        .task {
            guard let learnController = learnController else { return }
            
            let learnedLearnQuestionResults: [LearnQuestionResult]
            do {
                learnedLearnQuestionResults = try await learnController.allLearnedLearnQuestionResults
            } catch {
                // TODO: Handle Errors
                print("Error getting learned learn question results in LearnCompleteContainer... \(error)")
                return
            }
            
            learnedFlashCards = learnedLearnQuestionResults.compactMap(\.flashCard)
        }
    }
    
}

@available(iOS 17, *)
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
            LearnCompleteContainer(learnController: .constant(learnController))
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
