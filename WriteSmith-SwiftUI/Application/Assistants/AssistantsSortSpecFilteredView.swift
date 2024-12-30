//
//  AssistantsSortSpecFilteredView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/29/24.
//

import Foundation
import SwiftUI

struct AssistantsSortSpecFilteredView: View {
    
    @State var assistantCategory: AssistantCategories
    @Binding var selectedAssistant: Assistant?
    
    
    var body: some View {
//        NavigationStack {
            AssistantsCategoryFilteredView(
                category: State(initialValue: assistantCategory),
                selectedAssistant: $selectedAssistant)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let imageName = assistantCategory.imageName {
                        Image(imageName)
                            .resizable()
                            .frame(width: 48.0, height: 48.0)
                            .foregroundStyle(Colors.navigationItemColor)
                    } else {
                        Text(assistantCategory.displayName)
                            .font(.custom(Constants.FontName.black, size: 24.0))
                            .foregroundStyle(Colors.navigationItemColor)
                    }
                }
            }
//        }
    }
    
}


//#Preview {
//    
//    AssistantsSortSpecFilteredView(
//        sortSpec: AssistantSortModel.sortItems[0],
//        selectedAssistant: .constant(nil))
//    
//}
