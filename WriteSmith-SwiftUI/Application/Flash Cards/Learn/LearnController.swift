//
//  LearnController.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/19/24.
//

import Combine
import CoreData
import Foundation

// For this the strategy is to somehow load LearnQuestions from the FlashCards.
// TODO: Round incrementer
class LearnController: ObservableObject {
    
//    @Published var totalQuestions: Int = 0
    @Published var learnComplete: Bool = false // Set when nextRound is called when allNotLearnedQuestions guard is not empty falls through
    @Published var currentQuestion: (any LearnQuestion)?
    @Published var userSelectedAnswer: (any Equatable)?
    @Published var gameState: GameState
    @Published var round: Int = 0
    
    var correctQuestions: Int {
        allRoundQuestions.count - queuedRoundQuestions.count - (currentQuestion != nil ? 1 : 0) + (currentQuestionAnsweredCorrectly ? 1 : 0)
    }
    
    var roundComplete: Bool {
        queuedRoundQuestions.isEmpty && currentQuestion == nil
    }
    
    var allLearnedLearnQuestionResults: [LearnQuestionResult] {
        get async throws {
            let learnQuestionResultsFetchRequest = LearnQuestionResult.fetchRequest()
            learnQuestionResultsFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K >= %d", #keyPath(LearnQuestionResult.learnQuestionResultCollection), results, #keyPath(LearnQuestionResult.correctAttempts), maxCorrectAttemptsToConsiderLearned)
            return try await managedObjectContext.perform {
                try self.managedObjectContext.fetch(learnQuestionResultsFetchRequest)
            }
        }
    }
    
    private var currentQuestionAnsweredCorrectly: Bool = false // Flag to add a question to correctQuestions count to show user progress if they select a correct answer since it will not remove the next question incrementing the count until nextQuestion is called which happens when the user presses the next button
    
    private(set) var allRoundQuestions: [any LearnQuestion] = []
    private var queuedRoundQuestions: [any LearnQuestion] = []
    
    private(set) var results: LearnQuestionResultCollection
    private var managedObjectContext: NSManagedObjectContext
    private var maxQuestionCount: Int
    private var frontIsQuestion: Bool
    private var questionTypeRatios: [LearnQuestionType: Double]
//    private var amountOverMinimumCorrectToConsiderLearned: Int // The amount of correct answers over the minimum to consider the question learned and not queue into the round
    private var maxCorrectAttemptsToConsiderLearned: Int // The maximum amount of correct attempts before a question is considered learned, caluclated by minCorrectAttempts + amountOverMinimumCorrectToConsiderLearned
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var allNotLearnedFlashCards: [FlashCard] {
        get async throws {
            // Ensure unwrap flashCardCollection, otherwise return TODO: Handle Errors
            guard let flashCardCollection = results.flashCardCollection else {
                print("Could not unwrap FlashCardCollection in LearnController!")
                return []
            }
            
            // Get flashCards
            let flashCards: [FlashCard] = try await managedObjectContext.perform {
                // Get flash cards
                let flashCardsFetchRequest = FlashCard.fetchRequest()
                flashCardsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(FlashCard.flashCardCollection), flashCardCollection)
                return try self.managedObjectContext.fetch(flashCardsFetchRequest)
            }
            
            return flashCards.filter({$0.learnQuestionResult == nil || $0.learnQuestionResult!.correctAttempts < maxCorrectAttemptsToConsiderLearned})
        }
    }
    
//    private var currentMaxCorrectAttempts: Int {
//        get async throws {
//            let fetchRequest = LearnQuestionResult.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(LearnQuestionResult.learnQuestionResultCollection), results)
//            return try await managedObjectContext.perform { [self] in
//                let results = try managedObjectContext.fetch(fetchRequest)
//                return Int(results.map(\.correctAttempts).max() ?? 0)
//            }
//        }
//    }
//    
//    private var currentMinCorrectAttempts: Int {
//        get async throws {
//            // Get minimum correctCount of flashCards' learn question result if it exists
//            let fetchRequest = LearnQuestionResult.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(LearnQuestionResult.learnQuestionResultCollection), results)
//            return try await managedObjectContext.perform { [self] in
//                let results = try managedObjectContext.fetch(fetchRequest)
//                return Int(results.map(\.correctAttempts).min() ?? 0)
//            }
//        }
//    }
    
    enum GameState {
        case quiz
        case answerReveal
    }
    
    struct QuestionTypeRatios {
        let multipleChoice: Double
        let trueFalse: Double
        let write: Double
    }
    
    static func build(flashCardCollection: FlashCardCollection, maxQuestionCount: Int, amountOverMinimumCorrectToConsiderLearned: Int, questionTypeRatios: [LearnQuestionType: Double], frontIsQuestion: Bool, managedObjectContext: NSManagedObjectContext) async throws -> LearnController {
        let results = try await managedObjectContext.perform {
            if let learnQuestionResultCollection = flashCardCollection.learnQuestionResultCollection {
                return learnQuestionResultCollection
            } else {
                let learnQuestionResultCollection = LearnQuestionResultCollection(context: managedObjectContext)
                learnQuestionResultCollection.flashCardCollection = flashCardCollection
                learnQuestionResultCollection.startDate = Date()
                try managedObjectContext.save()
                return learnQuestionResultCollection
            }
        }
        
        return await LearnController(
            results: results,
            maxQuestionCount: maxQuestionCount,
            amountOverMinimumCorrectToConsiderLearned: amountOverMinimumCorrectToConsiderLearned,
            questionTypeRatios: questionTypeRatios,
            frontIsQuestion: frontIsQuestion,
            managedObjectContext: managedObjectContext)
    }
    
    init(results: LearnQuestionResultCollection, maxQuestionCount: Int, amountOverMinimumCorrectToConsiderLearned: Int, questionTypeRatios: [LearnQuestionType: Double], frontIsQuestion: Bool, managedObjectContext: NSManagedObjectContext) async {
        self.results = results
        self.managedObjectContext = managedObjectContext
        self.gameState = .quiz
        self.maxQuestionCount = maxQuestionCount
        self.frontIsQuestion = frontIsQuestion
        self.questionTypeRatios = questionTypeRatios
        
        // Get minimum correctCount of flashCards' learn question result if it exists
        let fetchRequest = LearnQuestionResult.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(LearnQuestionResult.learnQuestionResultCollection), results)
        let minimumCorrectAttempts: Int
        do {
            minimumCorrectAttempts = try await managedObjectContext.perform {
                let results = try managedObjectContext.fetch(fetchRequest)
                return Int(results.map(\.correctAttempts).min() ?? 0)
            }
        } catch {
            // TODO: Handle Errors
            print("Error setting minimumCorrectAttempts in LearnController, continuing... \(error)")
            minimumCorrectAttempts = 0
        }
        self.maxCorrectAttemptsToConsiderLearned = minimumCorrectAttempts + amountOverMinimumCorrectToConsiderLearned
        
        if let flashCardCollection = results.flashCardCollection {
            await nextRound()
        } else {
            // TODO: Handle Errors
            print("Could not unwrap flashCardCollection in LearnController!")
        }
        
        $userSelectedAnswer.sink(receiveValue: { answer in
            // Ensure unwrap answer, otherwise return
            guard let answer = answer else {
                return
            }
            
            // On Submit Answer
            if let currentQuestion = self.currentQuestion {
                let isCorrect: Bool
                if let multipleChoiceLearnQuestion = currentQuestion as? MultipleChoiceLearnQuestion {
                    if let answer = answer as? String,
                       multipleChoiceLearnQuestion.isCorrect(answer: answer) {
                        // Correct
                        isCorrect = true
                    } else {
                        // Incorrect
                        isCorrect = false
                    }
                    self.recordResult(isCorrect, question: multipleChoiceLearnQuestion)
                } else if let trueFalseLearnQuestion = currentQuestion as? TrueFalseLearnQuestion {
                    if let answer = answer as? Bool,
                       trueFalseLearnQuestion.isCorrect(answer: answer) {
                        // Correct
                        isCorrect = true
                    } else {
                        // Incorrect
                        isCorrect = false
                    }
                    self.recordResult(isCorrect, question: trueFalseLearnQuestion)
                } else if let writeLearnQuestion = currentQuestion as? WriteLearnQuestion {
                    if let answer = answer as? String,
                       writeLearnQuestion.isCorrect(answer: answer) {
                        // Correct
                        isCorrect = true
                    } else {
                        // Incorrect
                        isCorrect = false
                    }
                    self.recordResult(isCorrect, question: writeLearnQuestion)
                }
            }
            self.gameState = .answerReveal
        })
        .store(in: &cancellables)
    }
    
    func nextRound() async {
        // Get all not learned flash cards prefixed to maxQuestionCount
        let allNotLearnedFlashCards: [FlashCard]
        do {
            allNotLearnedFlashCards = Array(try await self.allNotLearnedFlashCards.prefix(maxQuestionCount))
        } catch {
            // TODO: Hanlde Errors
            print("Error getting allNotLearnedFlashCards in LearnController... \(error)")
            return
        }
        
        // Ensure allNotLearnedFlashCards is not empty, otherwise set learnComplete to true and return
        guard !allNotLearnedFlashCards.isEmpty else {
            learnComplete = true
            return
        }
        
        // Create questions
        let learnQuizGenerator = LearnQuizGenerator(
            flashCards: allNotLearnedFlashCards,
            frontIsQuestion: frontIsQuestion,
            ratios: questionTypeRatios)
        await MainActor.run {
            allRoundQuestions = learnQuizGenerator.generateQuiz()
            queuedRoundQuestions = allRoundQuestions
        }
        
        // Increment round
        await MainActor.run {
            round += 1
        }
        
        // Load next question
        await MainActor.run {
            nextQuestion()
        }
    }
    
    // Basically the learn questions should have correctAttempts from the minimum to the minimum plus the amount over the minimum correct to be queued
    
    func nextQuestion() {
        // If current question is answered incorrectly, append the question to the end of questions array
        if !currentQuestionAnsweredCorrectly,
           let currentQuestion = currentQuestion {
            queuedRoundQuestions.append(currentQuestion)
        }
        
        // Reset currentQuestionAnsweredCorrectly flag
        currentQuestionAnsweredCorrectly = false
        
        // Set userSelectedAnswer to nil
        userSelectedAnswer = nil
        
        // Set gameState back to quiz
        gameState = .quiz
        
        // If there are questions remaining set it to currentQuestion, otherwise set to nil
        if queuedRoundQuestions.count > 0 {
            currentQuestion = queuedRoundQuestions.remove(at: 0)
        } else {
            currentQuestion = nil
        }
    }
    
    private func recordResult(_ isCorrect: Bool, question: some LearnQuestion) {
        Task {
            do {
                try await managedObjectContext.perform { [self] in
                    // Create fetch request to get the learn question result for the flash card if it exists
                    let learnQuestionResultFetchRequest = LearnQuestionResult.fetchRequest()
                    learnQuestionResultFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K = %@", #keyPath(LearnQuestionResult.learnQuestionResultCollection), results, #keyPath(LearnQuestionResult.flashCard), question.flashCard)
                    let learnQuestionResults = try managedObjectContext.fetch(learnQuestionResultFetchRequest)
                    
                    // Get or create LearnQuestionResult
                    let learnQuestionResult: LearnQuestionResult = {
                        if let learnQuestionResult = learnQuestionResults.first {
                            return learnQuestionResult
                        } else {
                            let learnQuestionResult = LearnQuestionResult(context: managedObjectContext)
                            learnQuestionResult.learnQuestionResultCollection = results
                            learnQuestionResult.flashCard = question.flashCard
                            return learnQuestionResult
                        }
                    }()
                    
                    // Increment correctAttempts if correct
                    if isCorrect {
                        learnQuestionResult.correctAttempts += 1
                    }
                    
                    // Set recentlyIncorrect to inverse of isCorrect
                    learnQuestionResult.recentlyIncorrect = !isCorrect
                    
                    // Save managedContext
                    try managedObjectContext.save()
                }
            } catch {
                // TODO: Handle Errors
                print("Error recording learn question result in LearnController... \(error)")
            }
        }
        
        // Set currentQuestionAnsweredCorrectly flag
        self.currentQuestionAnsweredCorrectly = isCorrect
    }
    
    
}

enum LearnControllerError: Error {
    case GameComplete
}
