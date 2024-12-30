//
//  LearnQuizGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/19/24.
//

import Foundation

struct LearnQuizGenerator {
    
    let flashCards: [FlashCard]
    let frontIsQuestion: Bool
    let ratios: [LearnQuestionType: Double]
    
    func generateQuiz() -> [any LearnQuestion] {
        // Calculate the number of questions for each type
        var questionCounts: [LearnQuestionType: Int] = [:]
        let totalQuestions = flashCards.count
        var remainingQuestions = totalQuestions

        for type in LearnQuestionType.allCases {
            let ratio = ratios[type] ?? 0
            let count = Int((Double(totalQuestions) * ratio).rounded())
            questionCounts[type] = count
            remainingQuestions -= count
        }
        
        // Adjust for rounding errors
        if remainingQuestions > 0 {
            // Distribute remaining questions to types with the highest ratios
            let sortedTypes = LearnQuestionType.allCases.sorted { (ratios[$0] ?? 0) > (ratios[$1] ?? 0) }
            for type in sortedTypes {
                if remainingQuestions == 0 { break }
                questionCounts[type, default: 0] += 1
                remainingQuestions -= 1
            }
        }
        
        // Generate questions
        var questions: [any LearnQuestion] = []
        for (type, count) in questionCounts {
            // Skip if count is zero or negative
            if count <= 0 { continue }

            // Shuffle the flashCards to randomize selection
            let shuffledFlashCards = flashCards.shuffled()

            // Take the required number of flashcards for this question type
            let selectedFlashCards = shuffledFlashCards.prefix(count)

            for flashCard in selectedFlashCards {
                let question = generateQuestion(flashCard, ofType: type)
                questions.append(question)
            }
        }
        
        // Shuffle questions
        questions.shuffle()
        return questions
    }
    
    func generateQuestion(_ flashCard: FlashCard, ofType type: LearnQuestionType) -> any LearnQuestion {
        switch type {
        case .multipleChoice:
            // Get correct answer and random answers
            let correctAnswer = frontIsQuestion ? flashCard.back ?? "" : flashCard.front ?? ""
            let randomAnswers: [String] = {
                var randomAnswers: [String] = []
                for i in 0..<3 {
                    if let randomAnswer = getRandomAnswer(differentThan: [correctAnswer] + randomAnswers, answerIsBackOfFlashCard: true) {
                        randomAnswers.append(randomAnswer)
                    }
                }
                return randomAnswers
            }()
            
            // Define the answers array and correct answer index by inserting correct answer at a random place
            let insertionIndex = Int.random(in: 0..<(1 + randomAnswers.count))
            var answers = randomAnswers
            answers.insert(correctAnswer, at: insertionIndex)
            
            return MultipleChoiceLearnQuestion(
                question: frontIsQuestion ? flashCard.front ?? "" : flashCard.back ?? "",
                answers: answers,
                correctAnswerIndex: insertionIndex,
                flashCard: flashCard)
        case .trueFalse:
            // Get correct (true) or incorrect random (false) prompt
            let shouldBeTrue = Bool.random()
            
            let flashCardStatement = frontIsQuestion ? flashCard.front ?? "" : flashCard.back ?? ""
            let correctMatchingStatement = frontIsQuestion ? flashCard.back ?? "" : flashCard.front ?? ""
            
            // Get proposed matching statement as correct answer or from random card based on shouldBeTrue
            var proposedMatchingStatement: String
            if shouldBeTrue {
                proposedMatchingStatement = correctMatchingStatement
            } else {
                proposedMatchingStatement = getRandomAnswer(differentThan: [correctMatchingStatement], answerIsBackOfFlashCard: true) ?? "Error Creating Question"
            }
            
            return TrueFalseLearnQuestion(
                flashCardStatement: flashCardStatement,
                proposedMatchingStatement: proposedMatchingStatement,
                correctAnswer: shouldBeTrue,
                flashCard: flashCard)
        case .write:
            return WriteLearnQuestion(
                prompt: frontIsQuestion ? flashCard.front ?? "" : flashCard.back ?? "",
                correctAnswer: frontIsQuestion ? flashCard.back ?? "" : flashCard.front ?? "",
                flashCard: flashCard)
        }
    }
    
    private func getRandomAnswer(differentThan: [String], answerIsBackOfFlashCard: Bool) -> String? {
        // Collect all possible answers, excluding nils and empty strings
        let allAnswers = flashCards.compactMap { answerIsBackOfFlashCard ? $0.back : $0.front }.filter { !$0.isEmpty }
        
        // Filter out answers that are in 'differentThan'
        let possibleAnswers = allAnswers.filter { !differentThan.contains($0) }
        
        // If there are any possible answers, select one at random
        return possibleAnswers.randomElement()
    }
    
}
