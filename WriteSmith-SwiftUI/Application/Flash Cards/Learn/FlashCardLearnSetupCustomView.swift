//
//  FlashCardLearnSetupCustomView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/26/24.
//

import SwiftUI

struct FlashCardLearnSetupCustomView: View {
    
    @Binding var maxQuestionCount: Int
    @Binding var amountOverMinimumCorrectToConsiderLearned: Int
    @Binding var multipleChoiceQuestionRatio: Double
    @Binding var trueFalseQuestionRatio: Double
    @Binding var writeQuestionRatio: Double
    var onStart: () -> Void
    
    private let trueFalseToMultipleChoiceRatioRange: ClosedRange<Double> = 0...5
    
    private var amountOverMinimumCorrectToConsiderLearnedAsFloat: Binding<Float> {
        Binding(
            get: {
                Float(amountOverMinimumCorrectToConsiderLearned)
            },
            set: { value in
                amountOverMinimumCorrectToConsiderLearned = Int(value)
            })
    }
    
    private var trueFalseToMultipleChoiceRatio: Binding<Double> {
        Binding(
            get: {
                multipleChoiceQuestionRatio
            },
            set: { value in
                multipleChoiceQuestionRatio = value
                trueFalseQuestionRatio = 1 - value
            })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            // Title and subtitle
            VStack(alignment: .leading) {
                Text("Personalize to learn how you want.")
                    .font(.custom(Constants.FontName.body, size: 17.0))
            }
            
            // Max question count
            VStack(alignment: .leading) {
                Text("Max Questions")
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                TextField(value: $maxQuestionCount, formatter: NumberFormatter(), label: {
                    Text("Max Questions")
                })
                .padding()
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .font(.custom(Constants.FontName.body, size: 17.0))
            }
            
            // Amount over minimmum correct to consider learned
            VStack(alignment: .leading) {
                Text("Mastery Level")
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                Slider(
                    value: amountOverMinimumCorrectToConsiderLearnedAsFloat,
                    in: 0...5,
                    step: 1)
                HStack {
                    Text("Fewer Repititions")
                        .font(.custom(Constants.FontName.body, size: 14.0))
                    Spacer()
                    Text("Easier Memorization")
                        .font(.custom(Constants.FontName.body, size: 14.0))
                }
            }
            
            // Question ratios
            VStack(alignment: .leading) {
                Text("Question Spread")
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                Slider(
                    value: trueFalseToMultipleChoiceRatio,
                    in: trueFalseToMultipleChoiceRatioRange,
                    step: 0.1)
                HStack {
                    Text("True/False")
                        .font(.custom(Constants.FontName.body, size: 14.0))
                    Spacer()
                    Text("Multiple Choice")
                        .font(.custom(Constants.FontName.body, size: 14.0))
                }
            }
            
            Spacer()
            
            // Start button
            Button(action: onStart) {
                ZStack {
                    Text("Start")
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .font(.custom(Constants.FontName.heavy, size: 17.0))
                .foregroundStyle(Colors.elementTextColor)
                .padding()
                .background(Colors.elementBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        }
    }
    
}

@available(iOS 17, *)
#Preview {
    
    @Previewable @State var maxQuestionCount: Int = 0
    @Previewable @State var amountOverMinimumCorrectToConsiderLearned: Int = 2
    @Previewable @State var multipleChoiceQuestionRatio: Double = 0.9
    @Previewable @State var trueFalseQuestionRatio: Double = 0.1
    @Previewable @State var writeQuestionRatio: Double = 0.0
    
    return FlashCardLearnSetupCustomView(
        maxQuestionCount: $maxQuestionCount,
        amountOverMinimumCorrectToConsiderLearned: $amountOverMinimumCorrectToConsiderLearned,
        multipleChoiceQuestionRatio: $multipleChoiceQuestionRatio,
        trueFalseQuestionRatio: $trueFalseQuestionRatio,
        writeQuestionRatio: $writeQuestionRatio,
        onStart: {
            
        })
    .padding()
    .background(Colors.background)  
    
}
