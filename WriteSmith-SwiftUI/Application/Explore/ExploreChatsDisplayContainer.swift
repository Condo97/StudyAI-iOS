//
//  ExploreChatsDisplayContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/8/24.
//

import SwiftUI

struct ExploreChatsDisplayContainer: View {
    
    @ObservedObject var simpleChatGenerator: SimpleChatGenerator
    
    @State private var chats: [String] = []
    
    var body: some View {
        ExploreChatsDisplayView(
            chats: $chats)
        .onReceive(simpleChatGenerator.$generatedTexts) { newValue in
            chats = newValue.keys.sorted().compactMap { newValue[$0] }
        }
    }
    
}

//#Preview {
//    
//    return ExploreChatsDisplayContainer(
//        simpleChatGenerator: SimpleChatGenerator()
//    )
//    
//}
