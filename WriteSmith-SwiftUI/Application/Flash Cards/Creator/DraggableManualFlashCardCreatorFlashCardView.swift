////
////  DraggableManualFlashCardCollectionCreatorFlashCardView.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 8/12/24.
////
//
//import SwiftUI
//
//struct DraggableManualFlashCardCollectionCreatorFlashCardView<Content: View, BackgroundStyle: ShapeStyle>: View {
//    
//    var flashCard: FlashCardCollectionEditorFlashCard
//    var flashCardBackgroundStyle: BackgroundStyle
//    @ViewBuilder var content: Content
//
//    var body: some View {
//        ZStack {
//            content
//            FlashCardCollectionEditorFlashCardView(flashCard: flashCard)
//                .background(flashCardBackgroundStyle)
//        }
//    }
//    
//}
//
//#Preview {
//    
//    @State var isOpen: Bool = false
//    
//    return DraggableManualFlashCardCollectionCreatorFlashCardView(
//        flashCard: ManualFlashCardCollectionCreatorFlashCard(),
//        flashCardBackgroundStyle: Colors.foreground,
//        isOpen: $isOpen,
//        content: {
//            Text("Hi")
//        })
//    
//}
