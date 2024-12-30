//
//  AssistantsCategoryListView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/28/24.
//

import Foundation
import SwiftUI

struct AssistantsCategoryListView: View {
    
    @Binding var selectedSortItem: AssistantCategories?
    
    
    private let assistantSortItems: [AssistantCategories] = AssistantSortModel.sortItems.compactMap({$0 == .general || $0 == .other ? nil : $0})
    
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(assistantSortItems) { item in
                    Button(action: {
                        self.selectedSortItem = item
                    }) {
                        VStack {
                            if let imageName = item.imageName {
                                Image(imageName)
                                    .resizable()
                                    .frame(width: 32.0, height: 32.0)
                                    .padding(24)
                                    .background(Colors.foreground)
                                    .clipShape(RoundedRectangle(cornerRadius: 32.0))
                                    .foregroundStyle(Colors.textOnBackgroundColor)
                            }
                            
                            Text(item.displayName)
                                .font(.custom(Constants.FontName.body, size: 14.0))
                                .foregroundStyle(Colors.textOnBackgroundColor)
                        }
                    }
                    .padding([.leading, .trailing], 4)
//                    .bounceable()
                }
            }
            .padding([.leading, .trailing])
        }
        .scrollIndicators(.never)
    }
    
}

//#Preview {
//    
//    AssistantsCategoryListView(selectedSortItem: .constant(nil))
//    
//}
