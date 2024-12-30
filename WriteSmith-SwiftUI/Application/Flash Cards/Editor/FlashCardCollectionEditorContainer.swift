//
//  FlashCardCollectionEditorContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/16/24.
//

import SwiftUI

struct FlashCardCollectionEditorContainer: View {
    
    @Binding var isPresented: Bool
    var initialTitle: String
    var flashCardCollection: FlashCardCollection
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var titleText: String = ""
    @State private var flashCards: [FlashCardCollectionEditorFlashCard] = []
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            FlashCardCollectionEditorView(
                titleText: $titleText,
                flashCards: $flashCards)
            .navigationTitle(
                Text("Edit Flash Cards"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Colors.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await save()
                            await MainActor.run {
                                isPresented = false
                            }
                        }
                    }
                }
            }
            .overlay {
                if isLoading {
                    ZStack {
                        Colors.foreground
                            .opacity(0.6)
                        ProgressView()
                    }
                }
            }
            .task {
                // Defer setting isLoading to false
                defer {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
                
                // Set isLoading to true
                await MainActor.run {
                    isLoading = true
                }
                
                // Set flashCards
                let flashCards: [FlashCardCollectionEditorFlashCard]
                do {
                    flashCards = try await viewContext.perform {
                        let fetchRequest = FlashCard.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(FlashCard.flashCardCollection), flashCardCollection)
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FlashCard.index), ascending: true)] // TODO: Make sure this is sorted correctly
                        
                        let fetchedFlashCards = try viewContext.fetch(fetchRequest)
                        
                        return fetchedFlashCards.map({FlashCardCollectionEditorFlashCard(front: $0.front ?? "", back: $0.back ?? "")})
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error making flashCards array from CoreData in FlashCardCollectionEditor... \(error)")
                    return
                }
                
                await MainActor.run { [flashCards] in
                    self.titleText = self.initialTitle
                    self.flashCards = flashCards
                }
            }
        }
    }
    
    
    private func save() async {
        // TODO: This is somewhat repeated from ConversationFlashCardCollectionCreatorView and should probably be abstracted so that it can be reused in both places
        // TODO: Flash card versions.. a new one should be appended to FlashCardCollection with some sort of id either generated or the same if it exists already if we're going to reuse this logic, and the new one has a newer date, so that when we fetch FlashCardCollection it will always be the one with the latest date
        do {
            // Delete Flash Cards from Collection
            try await FlashCardCollectionCDHelper.deleteFlashCards(
                flashCardCollection: flashCardCollection,
                in: viewContext)
            
            // Create Flash Cards to Flash Card Collection
            for i in 0..<flashCards.count {
                try await FlashCardCDHelper.createFlashCard(
                    index: Int64(i),
                    front: flashCards[i].front,
                    back: flashCards[i].back,
                    to: flashCardCollection,
                    in: viewContext)
            }
        } catch {
            // TODO: Handle Errors
            print("Error creating and saving flash cards in FlashCardCollectionEditorContainer... \(error)")
        }
    }
    
}

//#Preview {
//    
//    FlashCardCollectionEditorContainer()
//    
//}
