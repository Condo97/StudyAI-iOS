//
//  FlashCardCollectionMiniView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/15/24.
//

import SwiftUI

struct FlashCardCollectionMiniView: View {
    
    @FetchRequest var flashCards: FetchedResults<FlashCard>
    var height: CGFloat// = 150
    var fontSize: CGFloat
    
    @State private var carouselIndex: Int = 0
    
    private var spacing: CGFloat {
        height * 1/10
    }
    
    private var itemWidth: CGFloat {
        height * 2
    }
    
    var body: some View {
        Carousel(
            index: $carouselIndex,
            fetchRequest: _flashCards,
            spacing: spacing,
            itemWidth: itemWidth,
            height: height) { flashCard in
                FlashCardContainer(
                    flashCard: flashCard,
                    fontSize: fontSize)
        }
        .tabViewStyle(PageTabViewStyle())
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
//    return FlashCardCollectionMiniView(
//        flashCards: FetchRequest(
//            sortDescriptors: [NSSortDescriptor(keyPath: \FlashCard.index, ascending: true)],
//            predicate: NSPredicate(format: "%K = %@", #keyPath(FlashCard.flashCardCollection), flashCardCollection)),
//        height: 150.0,
//        fontSize: 14.0)
//    .background(Colors.background)
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
