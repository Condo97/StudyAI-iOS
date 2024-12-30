//
//  Conversation SuggestionsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/3/24.
//

import Foundation
import SwiftUI

// Load with some chats, or it can pull them itself
// It can have one boolean that triggers it to hide and show, but when it shows it will always load... so like, isActive or something
// So when isPresented is false, it will just hide it, then when isActive is true it will get the suggestions from the server using the current chats and then display them when it is ready
// TODO: Allow for more suggestions to be loaded, using "Different Than" in the GenerateSuggestionsRequest

struct ConversationSuggestionsView: View {
    
    var conversation: Conversation
    @Binding var isShowing: Bool
//    @Binding var suggestionsInputs: [String]?
    @Binding var shouldGenerateSuggestions: Bool
    var onSelect: (Suggestion) -> Void
    
    private let numberOfSuggestionsToLoad: Int = 5
    private let numberOfChatsToIncludeInSuggestionsGenerationRequest: Int = 3
    private let staticSuggestions: [Suggestion] = [
        Suggestion(
            symbol: "\(Image(systemName: "rectangle.on.rectangle.angled"))",
            prompt: "Make flash cards.",
            requestsFlashCards: true)
    ]
    
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var generatedSuggestions: [Suggestion] = []
    
    var body: some View {
        // Should show up automatically if generatedSuggestions is not empty and isPresented is true, and not show if generatedSuggestions is empty OR isPresented is false meaning it will not show if isPresented is true but generatedSuggestions is empty or vice versa
        ZStack {
            if isShowing { // isShowing is here to ensure dual directonality with the binding so that isShowing can also be set
                SuggestionsView(
                    suggestions: staticSuggestions + generatedSuggestions,
                    onSelect: onSelect)
            } else {
                SuggestionsView(
                    suggestions: [],
                    onSelect: { _ in })
            }
        }
        .onAppear {
            setIsShowing(suggestions: generatedSuggestions)
        }
        .onChange(of: shouldGenerateSuggestions, perform: { newValue in
            if newValue {
                // If shouldGenerateSuggestions, clear generatedSuggestions and load new ones
                generatedSuggestions = []
                
                Task {
                    do {
                        generatedSuggestions = try await generateSuggestions()
                    } catch {
                        print("Error generating generatedSuggestions in SuggestionsView... \(error)")
                    }
                }
            }
        })
        .onChange(of: generatedSuggestions) { newValue in
            setIsShowing(suggestions: newValue)
        }
    }
    
    func generateSuggestions() async throws -> [Suggestion] {
        // Ensure and unwrap authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            print("Error ensuring authToken in SuggestionsView... \(error)")
            throw error
        }
        
        let suggestions = try await SuggestionsGenerator.generateSuggestions(
            numberOfSuggestionsToLoad: numberOfSuggestionsToLoad,
            numberOfChatsToUse: numberOfChatsToIncludeInSuggestionsGenerationRequest,
            authToken: authToken,
            for: conversation,
            in: viewContext)
        
        // Return suggestions mapped to Suggestions
        return suggestions.map({
            let splitStringWordAware = StringSplitterWordAware.splitStringWordAware($0)
            
            return Suggestion(
                topPart: splitStringWordAware.0,
                bottomPart: splitStringWordAware.1)
        })
    }
    
    func setIsShowing(suggestions: [Suggestion]) {
        // Set isShowing by newValue having one or more objects
        isShowing = suggestions.count > 0
    }
    
}

//#Preview {
//    
//    struct TestView: View {
//        
//        @State private var isActive: Bool = false
//        @State private var selected: Suggestion? = Suggestion(topPart: "Top Part", bottomPart: "Bottom Part")
//        
//        @State private var conversation: Conversation
//        
////        let fetchRequest = FetchRequest<Chat>(
////            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
////        )
//        
//        init() {
//            self._conversation = State(initialValue: Conversation(context: CDClient.mainManagedObjectContext))
//            
//            CDClient.mainManagedObjectContext.performAndWait {
//                try? CDClient.mainManagedObjectContext.save()
//            }
//        }
//        
//        var body: some View {
//            VStack {
//                Spacer()
//                
//                VStack {
//                    ConversationSuggestionsView(
////                        isActive: $isActive,
//                        conversation: conversation,
//                        isShowing: .constant(true),
//                        shouldGenerateSuggestions: .constant(true),
//                        onSelect: { suggestion in
//                            selected = suggestion
//                        }
//                    )
//                    .background(.white)
//                    
//                    Text("Tap Me")
//                }
//                .background(.gray)
//                
//                Spacer()
//            }
//            .onTapGesture {
//                isActive.toggle()
//                
//                print(isActive)
//            }
//            .onChange(of: selected, perform: { value in
//                print(value ?? "")
//            })
//        }
//        
//    }
//    
//    return TestView()
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//        .background(Color.blue)
//    
//}
//
