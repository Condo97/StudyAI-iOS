//
//  UltraToolbarItem.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI

struct UltraToolbarItem: ToolbarContent {
    
    var leadingPadding: CGFloat = -4
    var trailingPadding: CGFloat = -4
    
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            UltraButton()
                .padding(.leading, leadingPadding)
                .padding(.trailing, trailingPadding)
        }
    }
    
}

//#Preview {
//    NavigationStack {
//        ZStack {
//            
//        }
//        .toolbar {
//            LogoToolbarItem(elementColor: .constant(Colors.elementTextColor))
//            
//            AddChatToolbarItem(elementColor: .constant(Colors.elementTextColor), trailingPadding: -12, action: {
//                
//            })
//            
//            UltraToolbarItem()
//        }
//        .toolbarBackground(Colors.elementBackgroundColor)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .navigationBarTitleDisplayMode(.inline)
//        .environmentObject(RemainingUpdater())
//        .environmentObject(PremiumUpdater())
//        .environmentObject(ProductUpdater())
//    }
//}
