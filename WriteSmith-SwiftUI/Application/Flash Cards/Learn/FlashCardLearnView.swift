//
//  FlashCardLearnView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/19/24.
//

import SwiftUI

// TODO: Terms are considered complete when they are answered correctly twice
// TODO: Show the complete terms on the round complete page
// TODO: Round complete with round incrementer & continue to round 2 button
// TODO: Learn complete & restart reset button

struct FlashCardLearnView: View {
    
    @Binding var isPresented: Bool
    var flashCardCollection: FlashCardCollection
    @Binding var learnController_Binding: LearnController?
    @ObservedObject var learnController: LearnController
    
    @Environment(\.managedObjectContext) private var viewContext
    
//    @State private var learnController: LearnController?
    
    var body: some View {
        if learnController.learnComplete {
            // If learn complete show learn complete page
            LearnCompleteContainer(learnController: $learnController_Binding)
                .padding()
                .background(Colors.background)
        } else if learnController.roundComplete {
            // If game complete show game complete page
            FlashCardLearnRoundCompleteView(learnController: learnController)
                .padding()
                .background(Colors.background)
        } else {
            // If in game show the flash card learn view which is the game view that shows the game
            FlashCardLearnGameContainer(learnController: learnController)
                .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
}

//#Preview {
//    
//    let flashCardCollection = {
//        let learnQuestionResultCollection = LearnQuestionResultCollection(context: CDClient.mainManagedObjectContext)
//        learnQuestionResultCollection.flashCardCollection = FlashCardCollection(context: CDClient.mainManagedObjectContext)
//        
//        learnQuestionResultCollection.flashCardCollection?.addToFlashCards({
//            let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
//            flashCard.front = "Front1"
//            flashCard.back = "Back1"
//            return flashCard
//        }())
//        
//        learnQuestionResultCollection.flashCardCollection?.addToFlashCards({
//            let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
//            flashCard.front = "Front2"
//            flashCard.back = "Back2"
//            return flashCard
//        }())
//        
//        learnQuestionResultCollection.flashCardCollection?.addToFlashCards({
//            let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
//            flashCard.front = "Front3"
//            flashCard.back = "Back3"
//            return flashCard
//        }())
//        
//        return learnQuestionResultCollection.flashCardCollection!
//    }()
//    
//    FlashCardLearnView(flashCardCollection: flashCardCollection)
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
