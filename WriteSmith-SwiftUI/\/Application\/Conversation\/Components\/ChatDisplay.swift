import SwiftUI

struct ChatDisplay: View {
    @FetchRequest<Chat> var chats: FetchedResults<Chat>
    @ObservedObject var conversationChatGenerator: ConversationChatGenerator
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(chats) { chat in
                        ChatBubbleView(chat: chat, conversationChatGenerator: conversationChatGenerator)
                            .padding(.bottom, 8)
                            .padding([.leading, .trailing])
                    }
                    Spacer(minLength: 150.0)
                }
                .onAppear {
                    proxy.scrollTo("bottom_spacer", anchor: .bottom)
                }
            }
        }
    }
} 
