//
//  ConversationCreationAssistantsContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/2/24.
//

import SwiftUI

struct ConversationCreationAssistantsContainer: View {
    
    @Binding var isPresented: Bool
    @Binding var presentingConversation: Conversation?
//    var didCreateConversation: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    var body: some View {
        ConversationCreationAssistantsView(
            isPresented: $isPresented,
            onCreateConversation: { assistant in
                // TODO: Copied from ConversationViewContainer, simplify repeated functionality
                // Do light haptic
                HapticHelper.doLightHaptic()
                
                // Create new Conversation and set to conversation TODO: Better way of doing this
                do {
                    let conversation = try ConversationCDHelper.appendConversation(
                        modelID: presentingConversation?.modelID ?? GPTModels.gpt4oMini.rawValue,
                        assistant: assistant ?? presentingConversation?.assistant,
                        in: viewContext)
                    
                    self.presentingConversation = conversation
                } catch {
                    // TODO: Handle Errors
                    print("Error appending Conversation in ConversationView... \(error)")
                }
                
                // Dismiss
                DispatchQueue.main.async {
                    self.isPresented = false
                }
            })
    }
}

//#Preview {
//    ConversationCreationAssistantsContainer()
//}
