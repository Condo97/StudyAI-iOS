//
//  SuggestionsView.swift
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

struct SuggestionsView: View {
    
//    @Binding var selected: Suggestion?
    var suggestions: [Suggestion]
    var onSelect: (Suggestion) -> Void
    
    
//    private let numberOfChatsToIncludeInRequest: Int = 3
//    private let numberOfSuggestionsToLoad: Int = 5
    
    
//    (
//        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.date, ascending: false)]
//        predicate: <#T##NSPredicate?#>
//    )
//    private var chats
    
    
    
//    init(selected: Binding<Suggestion?>, suggestions: Binding<[Suggestion]>) {
//        self._selected = selected
//        self._suggestions = suggestions
//    }
    
    var body: some View {
        // Should show up automatically if suggestions is not empty and isPresented is true, and not show if suggestions is empty OR isPresented is false meaning it will not show if isPresented is true but suggestions is empty or vice versa
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(suggestions) { suggestion in
                    KeyboardDismissingButton(action: {
                        // Call onSelect with suggestion
                        onSelect(suggestion)
                    }) {
                        HStack {
                            if suggestion.requestsImageSend {
                                Text(Image(systemName: "camera.fill"))
                                    .font(.custom(Constants.FontName.body, size: 14.0))
                                    .foregroundStyle(Colors.text)
                                
                                Divider()
                                    .frame(height: 20.0)
                            }
                            
                            VStack(alignment: .leading) {
                                if let symbol = suggestion.symbol {
                                    Text(symbol)
                                        .font(.custom(Constants.FontName.body, size: 14.0))
                                        .foregroundStyle(Colors.text)
                                } else {
                                    Text(suggestion.topPart ?? "")
                                        .font(.custom(Constants.FontName.heavy, size: 12.0))
                                        .foregroundStyle(Colors.text)
                                    
                                    Text(suggestion.bottomPart ?? "")
                                        .font(.custom(Constants.FontName.body, size: 10.0))
                                        .foregroundStyle(Colors.text)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding([.leading, .trailing], 6)
                    .padding(6)
//                    .background(RoundedRectangle(cornerRadius: 14.0)
//                        .stroke(Colors.text.opacity(0.1), lineWidth: 1.0))
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                    .bounceable()
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding([.leading, .trailing])
        }
        .scrollIndicators(.never)
    }
    
}

//#Preview {
//        
//    @State var selected: Suggestion = Suggestion(topPart: "Top Part", bottomPart: "Bottom Part")
//        
//    return VStack {
//        Spacer()
//        
//        VStack {
//            SuggestionsView(
//                suggestions: InitialSuggestions.initialSuggestions,
//                onSelect: { suggestion in
//                    selected = suggestion
//                }
//            )
//            .background(.white)
//            
//            Text("Tap Me")
//        }
//        .background(.gray)
//        
//        Spacer()
//    }
//    .onChange(of: selected, perform: { value in
//        print(value ?? "")
//    })
//    
//}
