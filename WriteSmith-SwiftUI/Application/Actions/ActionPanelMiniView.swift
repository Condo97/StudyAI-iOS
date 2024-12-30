//
//  ActionPanelMiniView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/19/24.
//

import Foundation
import SwiftUI

struct ActionPanelMiniView: View {
    
    @State var panel: Panel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack {
                if let imageName = panel.imageName, let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 38.0)
                        .padding([.leading, .trailing], 4)
                } else if let emoji = panel.emoji {
                    Text(emoji)
                        .font(.system(size: 34.0))
                }
                
                Text(panel.title)
                    .font(.custom(Constants.FontName.heavy, size: 14.0))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Text(panel.description)
                .font(.custom(Constants.FontName.body, size: 11.0))
                .multilineTextAlignment(.leading)
                .opacity(0.8)
        }
    }
    
}

//#Preview {
//    
//    ActionPanelMiniView(panel: EssayActionView.actionPanel)
//    
//}
