//
//  FavoritesView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/29/24.
//

import CoreData
import SwiftUI

struct FavoritesView: View {
    
    @State var assistant: Assistant?
    
    @SectionedFetchRequest<String, Chat>(
        sectionIdentifier: \.daySectionIdentifier,
        sortDescriptors: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)],
        predicate: NSPredicate(format: "%K = %d", #keyPath(Chat.favorited), true),
        animation: .default)
    private var sectionedChatFetchRequest
    
    
    var body: some View {
        SectionedChatList(
            emptyTitleText: Text("No Favorites \(Image(systemName: "heart.fill"))"),
            emptyDescriptionText: Text("Tap and hold on a chat to add it to favorites."),
            sectionedChats: sectionedChatFetchRequest)
        .padding([.leading, .trailing])
        .background(Colors.background)
    }
    
}

//#Preview {
//    FavoritesView()
//}
