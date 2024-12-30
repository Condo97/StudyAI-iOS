//
//  ChatListContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/4/24.
//

import SwiftUI

struct ChatListContainer: View {
    
    var emptyTitleText: Text
    var emptyDescriptionText: Text?
    @FetchRequest var chats: FetchedResults<Chat>
    var onApplyFlashCardCollection: ((FlashCardCollection) -> Void)?
    var onSpeakText: ((String) -> Void)?
    
    var body: some View {
        ChatList(
            emptyTitleText: emptyTitleText,
            emptyDescriptionText: emptyDescriptionText,
            chats: chats,
            onApplyFlashCardCollection: onApplyFlashCardCollection,
            onSpeakText: onSpeakText)
    }
}

//#Preview {
//    
//    let conversationFetchRequest = Conversation.fetchRequest()
//    conversationFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Conversation.latestChatDate), ascending: true)]
//    
//    var conversation: Conversation?
//    try? CDClient.mainManagedObjectContext.performAndWait {
//        conversation = try CDClient.mainManagedObjectContext.fetch(conversationFetchRequest)[safe: 0]
//    }
//    
//    return NavigationStack {
//        ChatListContainer(
//            emptyTitleText: Text("No Chats"),
//            emptyDescriptionText: Text("Go back and add a chat!"),
//            chats: FetchRequest<Chat>(
//                sortDescriptors: [NSSortDescriptor(key: #keyPath(Chat.date), ascending: false)],
//                predicate: NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), conversation!),
//                animation: .default),
//            onApplyFlashCardCollection: { flashCardCollection in
//                
//            },
//            onSpeakText: { text in
//                
//            })
//    }
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
