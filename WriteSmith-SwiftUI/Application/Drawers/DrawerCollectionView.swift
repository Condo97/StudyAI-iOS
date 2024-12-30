//
//  DrawerCollectionView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import CoreData
import SwiftUI

struct DrawerCollectionView: View {
    
    @State var drawerCollection: GeneratedDrawerCollection
    @State var additionalPromptForRegeneration: String
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest private var drawers: FetchedResults<GeneratedDrawer>
    
    var allDrawersHeaderTitlesForRegeneration: String {
        let fetchRequest = GeneratedDrawer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(GeneratedDrawer.parentCollection), drawerCollection)
        
        return viewContext.performAndWait {
            do {
                return try viewContext.fetch(fetchRequest).map({
                    guard let header = $0.header ?? $0.headerOriginal,
                          !header.isEmpty,
                          let content = $0.content ?? $0.contentOriginal,
                          !content.isEmpty else {
                        return ""
                    }
                    
                    return String(
                        "Header"
                        +
                        header
                        +
                        "Content"
                        +
                        content
                    )
                }).joined(separator: ", ")
            } catch {
                // TODO: Handle Errors if Necessary
                print("Error fetching generated drawers in DrawerCollectionView... \(error)")
                return ""
            }
        }
    }
    
    
    init(drawerCollection: GeneratedDrawerCollection, additionalPromptForRegeneration: String) {
        self._drawerCollection = State(initialValue: drawerCollection)
        self._additionalPromptForRegeneration = State(initialValue: additionalPromptForRegeneration)
        
        self._drawers = FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(GeneratedDrawer.index), ascending: true)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(GeneratedDrawer.parentCollection), drawerCollection),
            animation: .default)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            Spacer()
            
            HStack {
                Text(drawerCollection.title ?? drawerCollection.titleOriginal ?? "")
                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                    .foregroundStyle(Colors.textOnBackgroundColor)
                
                Spacer()
            }
            
            ForEach(drawers) { drawer in
                UpdatingDrawerView(
                    drawer: drawer,
                    additionalPromptForRegeneration: additionalPromptForRegeneration + "\n\n" + allDrawersHeaderTitlesForRegeneration)
                .padding(12)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        }
        .toolbar {
            // TODO: Title as center navigation item, or maybe not maybe the title will just be above the ForEach
        }
        .scrollDismissesKeyboard(.interactively)
        .padding([.leading, .trailing])
        .background(Colors.background)
    }
    
}

//#Preview {
//    
//    let drawerCollection = GeneratedDrawerCollection(context: CDClient.mainManagedObjectContext)
//    drawerCollection.title = "Drawer Collection Title"
//    drawerCollection.titleOriginal = "Drawer Collection Title"
//    
//    let drawer1 = GeneratedDrawer(context: CDClient.mainManagedObjectContext)
//    drawer1.index = 1
//    drawer1.header = "Drawer 1 Title"
//    drawer1.headerOriginal = "Drawer 1 Title"
//    drawer1.content = "Drawer 1 content"
//    drawer1.contentOriginal = "Drawer 1 content"
//    drawer1.parentCollection = drawerCollection
//    
//    let drawer2 = GeneratedDrawer(context: CDClient.mainManagedObjectContext)
//    drawer2.index = 2
//    drawer2.header = "Drawer 2 Title"
//    drawer2.headerOriginal = "Drawer 2 Title"
//    drawer2.content = "Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2"
//    drawer2.contentOriginal = "Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2Test Content 2"
//    drawer2.parentCollection = drawerCollection
//    
//    let drawer3 = GeneratedDrawer(context: CDClient.mainManagedObjectContext)
//    drawer3.index = 3
//    drawer3.header = "Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3"
//    drawer3.headerOriginal = "Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3Test Header 3"
//    drawer3.content = "Test Content 3"
//    drawer3.contentOriginal = "Test Content 3"
//    drawer3.parentCollection = drawerCollection
//    
//    try? CDClient.mainManagedObjectContext.performAndWait {
//        try CDClient.mainManagedObjectContext.save()
//    }
//    
//    return NavigationStack {
//        DrawerCollectionView(
//            drawerCollection: drawerCollection,
//            additionalPromptForRegeneration: "Additional Prompt for Regeneration")
//    }
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
