//
//  ExploreChatsDisplayView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct ExploreChatsDisplayView: View {
    
//    var conversation: Conversation // TODO: FetchRequest and stuff
    @Binding var chats: [String]
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
    var body: some View {
        VStack {
            if !premiumUpdater.isPremium {
                BannerView(bannerID: Keys.Ads.Banner.exploreChatView)
            }
            
            Spacer(minLength: 20.0)
            
            List(chats, id: \.self) { chat in
                ExploreChatView(chat: chat)
                    .listRowBackground(Colors.background)
            }
            .buttonStyle(.plain)
            .listStyle(.plain)
            
//            if let streamingChat = streamingChat, !streamingChat.isEmpty {
//                ExploreChatView(chat: streamingChat)
//            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .toolbar {
            ShareToolbarItem(
                elementColor: .constant(Colors.navigationItemColor),
                placement: .topBarLeading,
                tightenLeadingSpacing: true)
            
            ToolbarItem(placement: .principal) {
                ZStack {
                    Text("StudyAI")
                        .font(.custom(Constants.FontName.black, size: 24.0))
                        .foregroundStyle(Colors.navigationItemColor)
                }
            }
            
            if !premiumUpdater.isPremium {
                UltraToolbarItem()
            }
        }
        .background(Colors.background)
    }
    
}

//#Preview {
//    NavigationStack {
//        ExploreChatsDisplayView(
//            chats: .constant([
//                "Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one! Chat 1, it's a long one!"
//            ]),
//            streamingChat: .constant("")
//        )
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
//        }
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarBackground(Colors.elementBackgroundColor, for: .navigationBar)
//    }
//    .environmentObject(RemainingUpdater())
//    .environmentObject(PremiumUpdater())
//    .environmentObject(ProductUpdater())
//}
