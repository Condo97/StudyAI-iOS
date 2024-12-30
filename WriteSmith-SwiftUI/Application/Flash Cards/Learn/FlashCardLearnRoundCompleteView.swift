//
//  FlashCardLearnRoundCompleteView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/22/24.
//

import SwiftUI

// How do we get if the whole game is complete? Maybe it can just set someting to gameComplete when calling the next round omg that is so good maybe I need to start writing things down to think about them lmao
// If all not learned flash cards is empty then the game is complete actually this one <--/

struct FlashCardLearnRoundCompleteView: View {
    
    @ObservedObject var learnController: LearnController
    
    @State private var totalTerms: Int?
    @State private var totalLearnedTerms: Int?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16.0) {
                // Round complete message TODO: Random encouraging message
                Text("Round \(learnController.round) complete!")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                
                // Progress (total with 2 correct)
                VStack(alignment: .leading) {
                    Text("Round \(learnController.round)")
                        .font(.custom(Constants.FontName.heavy, size: 11.0))
                    if let totalLearnedTerms = totalLearnedTerms,
                       let totalTerms = totalTerms,
                       totalLearnedTerms >= 0 {
                        Text("\(min(totalLearnedTerms, totalTerms))/\(totalTerms) terms")
                            .font(.custom(Constants.FontName.heavy, size: 11.0))
                        ProgressView(value: Float(totalLearnedTerms), total: Float(learnController.allRoundQuestions.count))
                            .progressViewStyle(.linear)
                    } else {
                        ProgressView()
                    }
                }
                
                // Terms
                Text("Terms from this round")
                ForEach(learnController.allRoundQuestions.indices, id: \.self) { allRoundQuestionIndex in
                    let question = learnController.allRoundQuestions[allRoundQuestionIndex]
                    FlashCardLearnRoundCompleteTermView(flashCard: question.flashCard)
                        .padding()
                        .background(Colors.foreground)
                }
                
                Spacer(minLength: 150.0)
            }
        }
        .overlay(alignment: .bottom) {
            // Next Round Button
            Button(action: {
                Task {
                    await learnController.nextRound()
                }
            }) {
                HStack {
                    Spacer()
                    Text("Next Round")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
            .padding(.vertical)
            .background(Colors.background)
        }
        .task {
            // Get total learned terms and total terms from learnController
            do {
                totalLearnedTerms = try await learnController.allLearnedLearnQuestionResults.count
                totalTerms = learnController.results.flashCardCollection?.flashCards?.count ?? 0
            } catch {
                // TODO: Handle Errors
                print("Error getting total learned terms: \(error.localizedDescription)")
            }
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
            FlashCardLearnRoundCompleteView(learnController: learnController)
                .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
                .background(Colors.background)
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
