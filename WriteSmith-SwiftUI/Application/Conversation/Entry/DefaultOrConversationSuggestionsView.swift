//
//  DefaultOrConversationSuggestionsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/29/24.
//

import SwiftUI
import UIKit

struct DefaultOrConversationSuggestionsView: View {
    
    var conversation: Conversation
    @Binding var isActive: Bool
    @Binding var isShowingConversationSuggestions: Bool
//    @FetchRequest<Chat> var chats: FetchedResults<Chat>
    var chats: FetchedResults<Chat>
    let onSelect: (_ text: String, _ image: UIImage?, _ imageURL: String?) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
//    private let numberOfChatsToIncludeInRequest: Int = 3
    
    @State private var defaultSuggestions: [Suggestion] = InitialSuggestions.initialSuggestions
    
    @State private var isShowingCameraView: Bool = false
    
    @State private var shouldGenerateConversationSuggestions: Bool = false
    
    @State private var selectedSuggestionForCameraView: Suggestion?
    
    var body: some View {
        // Suggestions
        ZStack {
            if chats.first(where: {$0.sender == Sender.user.rawValue}) == nil  {
                // Show default suggestion if first chat
                SuggestionsView(
                    suggestions: defaultSuggestions,
                    onSelect: onSelectSuggestion)
            } else {
                // Show conversation suggestions view if not first chat
                ConversationSuggestionsView(
                    conversation: conversation,
                    isShowing: $isShowingConversationSuggestions,
                    shouldGenerateSuggestions: $shouldGenerateConversationSuggestions,
                    onSelect: onSelectSuggestion)
            }
        }
        .fullScreenCover(isPresented: $isShowingCameraView, content: {
            ZStack {
                CaptureCameraViewControllerRepresentable(
                    //                isShowing: $isShowingCameraView,
                    reset: .constant(false), // TODO: Fix reset for capture camera view
                    withCropFrame: .constant(nil),
                    withImage: .constant(nil),
                    onAttach: { image, cropFrame, originalImage in
                        // Ensure unwrap selectedSuggestion, otherwise return
                        guard let selectedSuggestionForCameraView = selectedSuggestionForCameraView else {
                            // TODO: Handle Errors
                            return
                        }
                        
                        // Call onSelect with selectedSuggestion fullString and image
                        onSelect(selectedSuggestionForCameraView.fullPromptString, image, nil)
                        
                        // Dismiss camera view
                        isShowingCameraView = false
                    },
                    onScan: { scanText in
                        // Create input with suggestion and scanText or just scanText if suggestion cannot be unwrapped or its fullString is empty since fullString is not an optional so it doesn't need to be unwrapped just selectedSuggestion does lol ree aaaaa
                        let input: String = {
                            if let fullSuggestionString = selectedSuggestionForCameraView?.fullPromptString, !fullSuggestionString.isEmpty {
                                return fullSuggestionString + "\n\n" + scanText
                            }
                            
                            return scanText
                        }()
                        
                        // Call onSelect with input
                        onSelect(input, nil, nil)
                        
                        // Dismiss camera view
                        isShowingCameraView = false
                    })
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isShowingCameraView = false
                        }) {
                            Text(Image(systemName: "xmark"))
                                .font(.custom(Constants.FontName.body, size: 20.0))
                                .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                .padding()
                                .background(Colors.foreground)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .ignoresSafeArea()
        })
        .onChange(of: isActive) { newValue in
            if !newValue {
                // If isActive is set to false set isShowingConversationSuggestions to false
                isShowingConversationSuggestions = false // TODO: Is this a good place for this
            }
            shouldGenerateConversationSuggestions = newValue
//            if newValue {
//                suggestionsInputs = chats[0..<min(chats.count, numberOfChatsToIncludeInRequest)].compactMap({$0.text})
//            } else {
//                suggestionsInputs = nil
//            }
        }
        .onChange(of: isShowingCameraView) { newValue in
            // If camera view is dismissed set selectedSuggestionsForCameraView to nil to allow for the camera to be reopened
            if !newValue {
                selectedSuggestionForCameraView = nil
            }
        }
    }
    
    func onSelectSuggestion(suggestion: Suggestion) {
        // If selectedSuggestions requests image send open camera, otherwise call onSelect
        if suggestion.requestsImageSend {
            selectedSuggestionForCameraView = suggestion
            isShowingCameraView = true
        } else {
            onSelect(suggestion.fullPromptString, nil, nil)
        }
    }
    
}

//#Preview {
//    DefaultOrConversationSuggestionsView(
//        isActive: .constant(true),
//        onSelect: { suggestion in
//            
//        }
//    )
//}
