//
//  ConversationFlashCardCollectionCreatorView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import CoreData
import SwiftUI

struct ConversationFlashCardCollectionCreatorView: View {
    
    @Binding var isPresented: Bool
    var conversation: Conversation
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isShowingManualEntry: Bool = false
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        FlashCardCollectionCreatorContainer(
            onClose: {
                isPresented = false
            },
            onOpenManualEntry: {
                isShowingManualEntry = true
            },
            onSubmit: { textAttachment, imageDataAttachment in
                // Generate flash cards
                Task {
                    // Defer setting isLoading to false
                    defer {
                        DispatchQueue.main.async {
                            self.isLoading = false
                        }
                    }
                    
                    // Set isLoading to true
                    await MainActor.run {
                        self.isLoading = true
                    }
                    
                    // Ensure authToken, otherwise return
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle errors
                        print("Error ensureing AuthToken in ChatView... \(error)")
                        return
                    }
                    
                    // Generate flash cards
                    do {
                        try await ConversationFlashCardCollectionGenerator.generateFlashCards(
                            authToken: authToken,
                            promptText: textAttachment,
                            promptImageData: imageDataAttachment,
                            to: conversation,
                            in: viewContext)
                    } catch {
                        // TODO: Handle Errors
                        print("Error generating flash cards in ConversationFlashCardCreatorView... \(error)")
                        return
                    }
                    
                    // Dismiss
                    await MainActor.run {
                        isPresented = false
                    }
                }
            })
        .overlay {
            if isLoading {
                ZStack {
                    Colors.foreground
                        .opacity(0.4)
                    ProgressView()
                }
            }
        }
        .popover(isPresented: $isShowingManualEntry) {
            ManualFlashCardCollectionCreatorView(
                onClose: {
                    // Dismiss
                    isShowingManualEntry = false
                },
                onSave: { title, flashCards in
                    // Save to Conversation, since this is the creator it should overwrite the current flash cards.. though I guess maybe this should be changed TODO: Make it so that this can be used as an edit view as well, well now I made one but it's just copy-pasted the code so make it more abstract so it can be reused there and here
                    Task {
                        do {
                            // Create Flash Card Collection
                            let flashCardsCollection = try await FlashCardCollectionCDHelper.createFlashCardCollection(
//                                title: title,
                                in: viewContext)
                            
                            // Create Flash Cards to Flash Card Collection
                            for i in 0..<flashCards.count {
                                // If both front and back are empty continue
                                if flashCards[i].back.isEmpty && flashCards[i].front.isEmpty {
                                    continue
                                }
                                
                                // Create flash card
                                try await FlashCardCDHelper.createFlashCard(
                                    index: Int64(i),
                                    front: flashCards[i].front,
                                    back: flashCards[i].back,
                                    to: flashCardsCollection,
                                    in: viewContext)
                            }
                            
                            // Create Persistent Attachment Update Cached Text and Generated Title with Flash Card Collection
                            let flashCardsAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createFlashCardsAttachmentUpdateCachedTextAndGeneratedTitle(
                                flashCardCollection: flashCardsCollection,
                                title: title,
                                in: viewContext)
                            
                            // Append Persistent Attachment to Conversation
                            try await PersistentAttachmentCDHelper.update(flashCardsAttachment, conversation: conversation, in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error creating and saving flash cards in ManualFlashCardCollectionCreatorContainer... \(error)")
                        }
                    }
                    
                    // Dismiss both
                    isShowingManualEntry = false // TODO: This may not be necessary
                    isPresented = false
                })
        }
    }
    
}

//#Preview {
//    
//    ConversationFlashCardCollectionCreatorView()
//
//}
