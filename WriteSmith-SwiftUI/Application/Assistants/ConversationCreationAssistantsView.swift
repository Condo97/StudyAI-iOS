//
//  ConversationCreationAssistantsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/27/24.
//

import CoreData
import Foundation
import SwiftUI

struct ConversationCreationAssistantsView: View {
    
    @Binding var isPresented: Bool
    var onCreateConversation: (Assistant) -> Void
    
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @State private var faceAssistant: Assistant?
    @State private var selectedAssistant: Assistant?
    
    
    init(isPresented: Binding<Bool>, onCreateConversation: @escaping (Assistant) -> Void) {
        // Set parameters to variables
        self._isPresented = isPresented
        self.onCreateConversation = onCreateConversation
        
        // Set face assistant as assistant from CurrentAssistantPersistence TODO: This can maybe be even set in a view hirearchically above this one
        do {
            self._faceAssistant = State(initialValue: try CurrentAssistantPersistence.getAssistant(in: CDClient.mainManagedObjectContext))
        } catch {
            // TODO: Handle Errors
            print("Error getting assistant from CurrentAssistantPersistence in AssistantsView... \(error)")
        }
    }
    
    
    var body: some View {
        AssistantsView(
            isPresented: $isPresented,
            faceAssistant: $faceAssistant,
            selectedAssistant: $selectedAssistant)
        .onChange(of: selectedAssistant) { newValue in
            // Create and set Conversation with new Assistant
            if let assistant = newValue {
                // Create Conversation
                onCreateConversation(assistant)
//                
//                do {
//                    let conversation = try ConversationCDHelper.appendConversation(
//                        modelID: premiumUpdater.isPremium ? GPTModels.gpt4o.rawValue : GPTModels.gpt4oMini.rawValue,
//                        assistant: assistant,
//                        in: viewContext)
//                    
//                    self.conversation = conversation
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error appending Conversation in ConversationCreationAssistantsView... \(error)")
//                }
//                
//                // Call didSetConversation
//                didCreateConversation()
//                
//                // Set isPresented to false
//                isPresented = false
            }
        }
    }
    
}
