//
//  DrawerCollectionMiniView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import Foundation
import SwiftUI

struct DrawerCollectionMiniView: View {
    
    @State var drawerCollection: GeneratedDrawerCollection
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    var body: some View {
        VStack {
            HStack {
                Text(Image(systemName: "list.star"))
                    .font(.custom(Constants.FontName.body, size: 24.0))
                    .padding(8)
                    .background(Colors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                
                Text(drawerCollection.title ?? drawerCollection.titleOriginal ?? "*No Title*")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                
                Spacer()
            }
            
            if let subtitle = drawerCollection.subtitle ?? drawerCollection.subtitleOriginal {
                HStack {
                    Text(subtitle)
                        .font(.custom(Constants.FontName.body, size: 14.0))
                    
                    Spacer()
                }
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
//    return DrawerCollectionMiniView(drawerCollection: drawerCollection)
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
