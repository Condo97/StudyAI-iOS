//
//  ManualFlashCardCollectionCreatorView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct ManualFlashCardCollectionCreatorView: View {
    
    var onClose: () -> Void
    var onSave: (_ titleText: String, _ flashCards: [FlashCardCollectionEditorFlashCard]) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var titleText: String = ""
    @State private var flashCards: [FlashCardCollectionEditorFlashCard] = [
        FlashCardCollectionEditorFlashCard(),
        FlashCardCollectionEditorFlashCard()
    ]
//    Array(
//        repeating: FlashCardCollectionEditorFlashCard(),
//        count: 2)
    
    var body: some View {
        NavigationStack {
            FlashCardCollectionEditorView(
                titleText: $titleText,
                flashCards: $flashCards)
            .navigationTitle(
                Text("Create Flash Cards"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Colors.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", action: onClose)
                    .font(.custom(Constants.FontName.body, size: 17.0))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: {
                        onSave(titleText, flashCards)
                    })
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                }
            }
        }
    }
    
}

//#Preview {
//    
//    let conversation = try! CDClient.mainManagedObjectContext.fetch(Conversation.fetchRequest())[0] as Conversation
//    
//    return ManualFlashCardCollectionCreatorView(
//        onClose: {
//            
//        },
//        onSave: { titleText, flashCards in
//            
//        }
//    )
//    
//}
