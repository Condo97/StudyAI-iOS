//
//  ConversationFlashCardCollectionMiniContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/16/24.
//

import SwiftUI

struct ConversationFlashCardCollectionMiniContainer: View {
    
    var attachmentTitle: String
    var flashCardCollection: FlashCardCollection // TODO: Should this be observed
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Namespace private var namespace
    
    @State private var isExpanded: Bool = true
    
    @State private var isShowingEditor: Bool = false
    @State private var isShowingLearn: Bool = false
    
    var body: some View {
        // Flash Card Collection Mini Container
        VStack {
            if !isExpanded {
                HStack {
                    Spacer()
                    buttons
                        .matchedGeometryEffect(id: "buttons", in: namespace)
                }
            }
            FlashCardCollectionMiniContainer(
                flashCardCollection: flashCardCollection,
                height: isExpanded ? 150.0 : 50.0,
                fontSize: isExpanded ? 14.0 : 8.0)
        }
        .overlay(alignment: .topTrailing) {
            if isExpanded {
                buttons
                    .matchedGeometryEffect(id: "buttons", in: namespace)
            }
        }
        .fullScreenCover(isPresented: $isShowingEditor) {
            FlashCardCollectionEditorContainer(
                isPresented: $isShowingEditor,
                initialTitle: attachmentTitle,
                flashCardCollection: flashCardCollection)
        }
        .fullScreenCover(isPresented: $isShowingLearn) {
            NavigationStack {
                FlashCardLearnContainer(
                    isPresented: $isShowingLearn,
                    flashCardCollection: flashCardCollection)
            }
        }
    }
    
    var buttons: some View {
        HStack {
            // Learn Button
            Button(action: {
                withAnimation(.bouncy(duration: 0.5)) {
                    isShowingLearn = true
                }
            }) {
                Image(systemName: "rectangle.badge.checkmark") // TODO: Better symbol
                    .frame(width: 18.0, height: 18.0)
                    .foregroundStyle(colorScheme == .dark ? Colors.elementTextColor : Colors.elementBackgroundColor)
                    .padding()
                    .background(
                        ZStack {
                            if colorScheme == .dark {
                                Circle().stroke(.white.opacity(0.2), lineWidth: 0.5)
                                Circle().fill(Colors.foreground)
                            } else {
                                Circle().stroke(.black.opacity(0.2), lineWidth: 0.5)
                                Circle().fill(Colors.foreground)
                            }
                        })
            }
            
            // Edit Button
            Button(action: {
                withAnimation(.bouncy(duration: 0.5)) {
                    isShowingEditor = true
                }
            }) {
                Image(systemName: "pencil")
                    .frame(width: 18.0, height: 18.0)
                    .foregroundStyle(colorScheme == .dark ? Colors.elementTextColor : Colors.elementBackgroundColor)
                    .padding()
                    .background(
                        ZStack {
                            if colorScheme == .dark {
                                Circle().stroke(.white.opacity(0.2), lineWidth: 0.5)
                                Circle().fill(Colors.foreground)
                            } else {
                                Circle().stroke(.black.opacity(0.2), lineWidth: 0.5)
                                Circle().fill(Colors.foreground)
                            }
                        })
            }
            
            // Collapse or Expand Button
            Button(action: {
                withAnimation(.bouncy(duration: 0.5)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "chevron.up")
                    .frame(width: 18.0, height: 18.0)
                    .foregroundStyle(colorScheme == .dark ? Colors.elementTextColor : Colors.elementBackgroundColor)
                    .rotationEffect(.degrees(isExpanded ? 0.0 : 180.0))
                    .padding()
                    .background(
                        ZStack {
                            if colorScheme == .dark {
                                Circle().stroke(.white.opacity(0.2), lineWidth: 0.5)
                                Circle().fill(Colors.foreground)
                            } else {
                                Circle().stroke(.black.opacity(0.2), lineWidth: 0.5)
                                Circle().fill(Colors.foreground)
                            }
                        })
            }
        }
        .padding(.trailing)
    }
    
}

//#Preview {
//    
//    let flashCardCollection = CDClient.mainManagedObjectContext.performAndWait {
//        let flashCardCollection = FlashCardCollection(context: CDClient.mainManagedObjectContext)
//        
//        for i in 0..<5 {
//            let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
//            flashCard.index = Int64(i)
//            flashCard.front = "Front \(i)"
//            flashCard.back = "Back \(i)"
//            flashCard.flashCardCollection = flashCardCollection
//        }
//        
//        try! CDClient.mainManagedObjectContext.save()
//        
//        return flashCardCollection
//    }
//    
//    return ConversationFlashCardCollectionMiniContainer(
//        attachmentTitle: "Attachment Title",
//        flashCardCollection: flashCardCollection)
//    
//}
