//
//  ConversationCreationAssistantsSortSpecView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/28/24.
//

import CoreData
import Foundation
import SwiftUI

struct ConversationCreationAssistantsSortSpecFilteredView: View {
    
    @Binding var conversation: Conversation?
    @Binding var isPresented: Bool
    @State var selectedSortItem: AssistantCategories
    
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedAssistant: Assistant?
    
    var body: some View {
        AssistantsSortSpecFilteredView(
            assistantCategory: selectedSortItem,
            selectedAssistant: $selectedAssistant)
        .onChange(of: selectedAssistant) { newValue in
            if let selectedAssistant = selectedAssistant {
                // Create Conversation for selectedAssistant and set to Conversation
                do {
                    let conversation = try ConversationCDHelper.appendConversation(
                        modelID: premiumUpdater.isPremium ? GPTModels.gpt4o.rawValue : GPTModels.gpt4oMini.rawValue,
                        assistant: selectedAssistant,
                        in: viewContext)
                    
                    self.conversation = conversation
                } catch {
                    // TODO: Handle Errors
                    print("Error appending Conversation in ConversationCreationAssistantsSortSpecFilteredView... \(error)")
                }
                
                // Set isPresented to false
                isPresented = false
            }
        }
    }
    
}

//#Preview {
//    ConversationCreationAssistantsSortSpecFilteredView()
//}
