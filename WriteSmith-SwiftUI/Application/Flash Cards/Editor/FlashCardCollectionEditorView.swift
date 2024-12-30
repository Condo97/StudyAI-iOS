//
//  FlashCardCollectionEditorView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct FlashCardCollectionEditorView: View {
    
    @Binding var titleText: String
    @Binding var flashCards: [FlashCardCollectionEditorFlashCard]
    
    @State private var swipedOpenFlashCard: FlashCardCollectionEditorFlashCard?
    
    var body: some View {
        ScrollView {
            VStack {
                FlashCardCollectionEditorTextField(
                    subheading: "Title",
                    placeholder: "Subject, chapter, unit",
                    text: $titleText)
                .padding()
                
                ForEach(flashCards) { flashCard in
                    var isOpen: Binding<Bool> {
                        Binding(
                            get: {
                                swipedOpenFlashCard === flashCard
                            },
                            set: { value in
                                swipedOpenFlashCard = value ? flashCard : nil
                            })
                    }
                    
                    ZStack {
                        HStack {
                            Spacer()
                            Button("\(Image(systemName: "xmark")) Delete") {
                                flashCards.removeAll(where: {$0 === flashCard})
                            }
                            .foregroundStyle(Color(.systemRed))
                        }
                        .padding(.horizontal)
                        FlashCardCollectionEditorFlashCardView(flashCard: flashCard)
                            .padding()
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 2.0))
//                            .shadow(radius: 1)
                            .draggable(
                                isOpen: isOpen,
                                revealWidth: 150.0)
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    flashCards.append(FlashCardCollectionEditorFlashCard())
                }) {
                    HStack {
                        Spacer()
                        Text("+ Card")
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                        Spacer()
                    }
                    .padding(.vertical)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 2.0))
                }
                .padding(.horizontal)
            }
        }
        .background(Colors.background)
    }
    
}

//#Preview {
//    
//    FlashCardCollectionEditorView(
//        titleText: .constant(""),
//        flashCards: .constant([
//            FlashCardCollectionEditorFlashCard(),
//            FlashCardCollectionEditorFlashCard()
//        ])
//    )
//    
//}
