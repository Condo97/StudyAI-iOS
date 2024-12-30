//
//  FlashCardLearnContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/22/24.
//

import SwiftUI

struct FlashCardLearnContainer: View {
    
    @Binding var isPresented: Bool
    var flashCardCollection: FlashCardCollection
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var learnController: LearnController?
    
    var body: some View {
        Group {
            if let learnController = learnController {
                FlashCardLearnView(
                    isPresented: $isPresented,
                    flashCardCollection: flashCardCollection,
                    learnController_Binding: $learnController,
                    learnController: learnController)
            } else {
                FlashCardLearnSetupView(
                    learnController: $learnController,
                    flashCardCollection: flashCardCollection)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("\(Image(systemName: "xmark"))") {
                    isPresented = false
                }
                
                Button("\(Image(systemName: "gear"))") {
                    // TODO: Settings
                }
            }
        }
    }
    
}

#Preview {
    
    NavigationStack {
        FlashCardLearnContainer(
            isPresented: .constant(true),
            flashCardCollection: FlashCardCollection(context: CDClient.mainManagedObjectContext)
        )
    }
    
}
