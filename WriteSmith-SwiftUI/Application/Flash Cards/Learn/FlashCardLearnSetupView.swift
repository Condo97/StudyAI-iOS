//
//  FlashCardLearnSetupView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/26/24.
//

import SwiftUI

struct FlashCardLearnSetupView: View {
    
    @Binding var learnController: LearnController?
    var flashCardCollection: FlashCardCollection
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var maxQuestionCount: Int = 20
    @State private var amountOverMinimumCorrectToConsiderLearned: Int = 2
    @State private var multipleChoiceQuestionRatio: Double = 0.9
    @State private var trueFalseQuestionRatio: Double = 0.1
    @State private var writeQuestionRatio: Double = 0.0
    
    @State private var isLoading: Bool = false
    
    @State private var isShowingCustomizeSetup: Bool = false
    
    var body: some View {
        // Welcome to Learn, choose how you want to study today (quickly study has a max of 1 total correct over the minimum correct to learn all terms, memorize it all has a max of 2, there is also a customize button that pulls up the fine grained settings)
        ScrollView {
            VStack(alignment: .leading) {
                //            Text("Learn")
                Text("Choose how you want to study.")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                    .padding()
                FlashCardLearnSetupStudyStyleButton(
                    title: "Quickly Study",
                    subtitle: "Build your short-term memory",
                    detailDisclosure: HStack {
                        Image(systemName: "bolt")
                        Image(systemName: "chevron.right")
                    }, // TODO: Replace with a cool image
                    action: {
                        maxQuestionCount = 10
                        amountOverMinimumCorrectToConsiderLearned = 1
                        multipleChoiceQuestionRatio = 0.9
                        trueFalseQuestionRatio = 0.1
                        writeQuestionRatio = 0.0
                        Task {
                            await setupLearnController()
                        }
                    })
                .foregroundStyle(Colors.text)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding()
                
                FlashCardLearnSetupStudyStyleButton(
                    title: "Learn it All",
                    subtitle: "Build your long-term memory",
                    detailDisclosure: HStack {
                        Image(systemName: "brain")
                        Image(systemName: "chevron.right")
                    }, // TODO: Replace with a cool image
                    action: {
                        maxQuestionCount = 20
                        amountOverMinimumCorrectToConsiderLearned = 2
                        multipleChoiceQuestionRatio = 0.9
                        trueFalseQuestionRatio = 0.1
                        writeQuestionRatio = 0.0
                        Task {
                            await setupLearnController()
                        }
                    })
                .foregroundStyle(Colors.text)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding()
                
                FlashCardLearnSetupStudyStyleButton(
                    title: "Custom",
                    subtitle: "Setup your own study tool",
                    detailDisclosure: HStack {
                        Image(systemName: "pencil.line")
                        Image(systemName: "chevron.right")
                    }, // TODO: Replace with a cool image
                    action: {
                        isShowingCustomizeSetup = true
                    })
                .foregroundStyle(Colors.text)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding()
            }
        }
        .background(Colors.background)
        .navigationTitle("Learn")
        .navigationDestination(isPresented: $isShowingCustomizeSetup) {
            FlashCardLearnSetupCustomView(
                maxQuestionCount: $maxQuestionCount,
                amountOverMinimumCorrectToConsiderLearned: $amountOverMinimumCorrectToConsiderLearned,
                multipleChoiceQuestionRatio: $multipleChoiceQuestionRatio,
                trueFalseQuestionRatio: $trueFalseQuestionRatio,
                writeQuestionRatio: $writeQuestionRatio,
                onStart: {
                    isShowingCustomizeSetup = false
                    Task {
                        await setupLearnController()
                    }
                })
            .padding()
            .background(Colors.background)  
            .navigationTitle("Custom Learn")
        }
    }
    
    func setupLearnController() async {
        defer {
            DispatchQueue.main.async { [self] in
                isLoading = false
            }
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            learnController = try await LearnController.build(
                flashCardCollection: flashCardCollection,
                maxQuestionCount: maxQuestionCount,
                amountOverMinimumCorrectToConsiderLearned: amountOverMinimumCorrectToConsiderLearned,
                questionTypeRatios: [
                    .multipleChoice: multipleChoiceQuestionRatio,
                    .trueFalse: trueFalseQuestionRatio,
                    .write: writeQuestionRatio
                ],
                frontIsQuestion: true,
                managedObjectContext: viewContext)
        } catch {
            // TODO: Handle Errors
        }
    }
    
}

#Preview {
    
    NavigationStack {
        FlashCardLearnSetupView(
            learnController: .constant(nil),
            flashCardCollection: FlashCardCollection(context: CDClient.mainManagedObjectContext))
    }
    
}
