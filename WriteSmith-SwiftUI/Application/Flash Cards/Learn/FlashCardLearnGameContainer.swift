//
//  FlashCardLearnGameContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/22/24.
//

import SwiftUI

struct FlashCardLearnGameContainer: View {
    
    @ObservedObject var learnController: LearnController
    
    var body: some View {
        FlashCardLearnGameView(learnController: learnController)
            .padding()
            .background(Colors.background)
            .overlay(alignment: .top) {
                if learnController.correctQuestions <= learnController.allRoundQuestions.count {
                    ProgressView(value: Float(max(learnController.correctQuestions, 0)), total: Float(max(learnController.allRoundQuestions.count, 0)))
                        .progressViewStyle(.linear)
                }
            }
    }
    
}

//#Preview {
//    
//    FlashCardLearnGameContainer()
//    
//}
