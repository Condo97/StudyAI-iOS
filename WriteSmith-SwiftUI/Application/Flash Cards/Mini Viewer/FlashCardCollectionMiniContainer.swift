//
//  FlashCardCollectionMiniContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/15/24.
//

import SwiftUI

struct FlashCardCollectionMiniContainer: View {
    
    var flashCardCollection: FlashCardCollection // TODO: Should this be observed
    var height: CGFloat// = 150
    var fontSize: CGFloat
    
    var body: some View {
        FlashCardCollectionMiniView(
            flashCards: FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \FlashCard.index, ascending: true)],
                predicate: NSPredicate(format: "%K = %@", #keyPath(FlashCard.flashCardCollection), flashCardCollection)),
            height: height,
            fontSize: fontSize)
    }
    
}

//#Preview {
//    
//    let flashCardCollection = CDClient.mainManagedObjectContext.performAndWait {
//        let flashCardCollection = FlashCardCollection(context: CDClient.mainManagedObjectContext)
//        
//        for i in 0..<5 {
//            let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
//            flashCard.index = Int64(i)
//            flashCard.front = "Front \(i)"
//            flashCard.back = "Back \(i)"
//            flashCard.flashCardCollection = flashCardCollection
//        }
//        
//        try! CDClient.mainManagedObjectContext.save()
//        
//        return flashCardCollection
//    }
//    
//    return FlashCardCollectionMiniContainer(
//        flashCardCollection: flashCardCollection,
//        height: 150.0,
//        fontSize: 14.0)
//    
//}
