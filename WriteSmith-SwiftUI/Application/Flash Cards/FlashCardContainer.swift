//
//  FlashCardContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/15/24.
//

import SwiftUI

struct FlashCardContainer: View {
    
    @ObservedObject var flashCard: FlashCard
    var fontSize: CGFloat
    
    var body: some View {
        ZStack {
            FlashCardView(
                front: flashCard.front ?? "*No Content*",
                back: flashCard.back ?? "*No Content*",
                fontSize: fontSize)
        }
    }
    
}


//#Preview {
//    
//    @State var isShowingFront: Bool = true
//    
//    let flashCard = FlashCard(context: CDClient.mainManagedObjectContext)
//    flashCard.index = 0
//    flashCard.front = "Front"
//    flashCard.back = "Back"
//    
//    try! CDClient.mainManagedObjectContext.save()
//    
//    return FlashCardContainer(
//        flashCard: flashCard,
//        fontSize: 14.0
//    )
//    
//}
