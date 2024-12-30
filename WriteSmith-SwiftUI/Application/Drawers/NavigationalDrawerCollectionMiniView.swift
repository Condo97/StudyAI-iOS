//
//  NavigationalDrawerCollectionMiniView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import SwiftUI

struct NavigationalDrawerCollectionMiniView: View {
    
    @State var drawerCollection: GeneratedDrawerCollection
    
    
    @State private var isShowingDrawerCollection: Bool = false
    
    var body: some View {
        Button(action: {
            isShowingDrawerCollection.toggle()
        }) {
            HStack(spacing: 2.0) {
                DrawerCollectionMiniView(drawerCollection: drawerCollection)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .imageScale(.medium)
            }
        }
        .navigationDestination(isPresented: $isShowingDrawerCollection) {
            DrawerCollectionView(
                drawerCollection: drawerCollection,
            additionalPromptForRegeneration: "")
                .toolbar {
                    // TODO: Toolbar title
                }
        }
    }
    
}

//#Preview {
//    
//    let fetchRequest = GeneratedDrawerCollection.fetchRequest()
//    
//    let drawerCollection = try! CDClient.mainManagedObjectContext.performAndWait {
//        let result = try CDClient.mainManagedObjectContext.fetch(fetchRequest)[0]
//        result.subtitle = "Test subtitle"
//        result.subtitleOriginal = "Test subtitle"
//        
//        try CDClient.mainManagedObjectContext.save()
//        
//        return result
//    }
//    
//    return NavigationalDrawerCollectionMiniView(drawerCollection: drawerCollection)
//    
//}
