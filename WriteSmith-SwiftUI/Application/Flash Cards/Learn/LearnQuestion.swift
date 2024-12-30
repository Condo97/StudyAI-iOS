//
//  LearnQuestion.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/19/24.
//

import Foundation

enum LearnQuestionType: CaseIterable {
    
    case multipleChoice
    case trueFalse
    case write
    
}

protocol LearnQuestion {
    associatedtype T: Equatable
    var correctAnswer: T { get }
    var flashCard: FlashCard { get }
    var type: LearnQuestionType { get }
}
extension LearnQuestion {
    func isCorrect(answer: T) -> Bool {
        answer == correctAnswer
    }
}

struct MultipleChoiceLearnQuestion: LearnQuestion {
    
    var question: String
    var answers: [String]
    var correctAnswerIndex: Int
    var correctAnswer: String { answers[correctAnswerIndex] }
    var flashCard: FlashCard
    let type: LearnQuestionType = .multipleChoice
    
}

struct TrueFalseLearnQuestion: LearnQuestion {
    
    var flashCardStatement: String
    var proposedMatchingStatement: String
    var correctAnswer: Bool
    var flashCard: FlashCard
    let type: LearnQuestionType = .trueFalse
    
}

struct WriteLearnQuestion: LearnQuestion {
    
    var prompt: String
    var correctAnswer: String
    var flashCard: FlashCard
    let type: LearnQuestionType = .write
    
}
