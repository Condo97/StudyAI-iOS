//
//  UltraButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/27/23.
//

import SwiftUI

struct UltraButton: View {
    
    var sparkleDiameter: CGFloat = 28.0
    var cornerRadius: CGFloat = 24.0
    var horizontalSpacing: CGFloat = 4.0
    var lineWidth: CGFloat = 2.0
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    @State private var isShowingUltraView: Bool = false
    
    private var sparkleImageName: String {
        colorScheme == .dark ? Constants.ImageName.sparkleDarkGif : Constants.ImageName.sparkleLightGif
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                // Show Ultra View
                isShowingUltraView = true
                
                // Do light haptic
                HapticHelper.doLightHaptic()
            }) {
                HStack(spacing: horizontalSpacing) {
                    SwiftyGif(name: sparkleImageName)
                        .frame(width: sparkleDiameter, height: sparkleDiameter)
                }
                .foregroundStyle(Colors.navigationItemColor)
//                .padding(innerPadding)
//                .padding([.leading, .trailing], innerPadding / 2)
//                .background(
//                    ZStack {
////                        RoundedRectangle(cornerRadius: cornerRadius)
////                            .fill(Colors.elementTextColor)
//                        RoundedRectangle(cornerRadius: cornerRadius)
//                            .stroke(Colors.navigationItemColor, lineWidth: 2.0)
//                    }
//                )
            }
            .bounceable()
        }
        .ultraViewPopover(isPresented: $isShowingUltraView)
    }
    
}

//#Preview {
//    UltraButton()
//        .background(.yellow)
//        .environmentObject(RemainingUpdater())
//        .environmentObject(PremiumUpdater())
//        .environmentObject(ProductUpdater())
//}
