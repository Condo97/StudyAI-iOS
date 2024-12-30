//
//  ConversationAttachmentsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import CoreData
import PDFKit
import SwiftUI

struct ConversationAttachmentsView: View {
    
    var conversation: Conversation
//    var conversationChatGenerator: ConversationChatGenerator
    @Binding var doGenerateBlankRemoveFirstChatIfInConversation: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @State private var imageAttachment: PersistentAttachment?
    @State private var pdfAttachment: PersistentAttachment?
    @State private var voiceAttachment: PersistentAttachment?
    @State private var webpageAttachment: PersistentAttachment?
    
    @State private var alertShowingErrorAttaching: Bool = false
    
    var body: some View {
        AttachmentsContainer(
            displayStyle: .horizontalScroll,
            imageAttachment: $imageAttachment,
            pdfAttachment: $pdfAttachment,
            voiceAttachment: $voiceAttachment,
            webpageAttachment: $webpageAttachment)
        .onChange(of: imageAttachment) { newValue in
            Task {
                // If persistentAttachment can be unwrapped the image was attached successfully
                if let persistentAttachment = newValue {
                    // Update persistentAttachment with conversation
                    do {
                        try await PersistentAttachmentCDHelper.update(persistentAttachment, conversation: conversation, in: viewContext)
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error updating persistentAttachment's conversation in ConversationAttachmentsView... \(error)")
                        await MainActor.run {
                            alertShowingErrorAttaching = true
                        }
                    }
                    
                    // Remove Assistant text from behavior TODO: This should definitely be done somewhere else or Assistants should be handled better, like copying over important data to a separate object and then being able to control the Assistant's prompt independently like that, but for the time being it needs to be done for all of the attachments
                    do {
                        try await ConversationCDHelper.removeAssistantTextFromBehavior(
                            for: conversation,
                            in: viewContext)
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error removing assistant text from behavior in AttachmentsView... \(error)")
                        await MainActor.run {
                            alertShowingErrorAttaching = true
                        }
                    }
                    
                    // Generate attachment summary by generating blank and removing first chat if necessary
                    doGenerateBlankRemoveFirstChatIfInConversation = true
//                    do {
//                        // Ensure unwrap authToken
//                        let authToken = try await AuthHelper.ensure()
//                        
//                        // Generate attachment summary by generating blank and removing first chat if necessary
//                        do {
//                            try await conversationChatGenerator.generateBlankRemoveFirstChatIfInConversation(
//                                authToken: authToken,
//                                conversation: conversation,
//                                isPremium: premiumUpdater.isPremium,
//                                model: GPTModelHelper.currentChatModel,
//                                in: viewContext)
//                        } catch {
//                            // TODO: Handle Errors if Necessary
//                            print("Error generating blank removing first chat if in conversation in ConversationAttachmentsView, continuing... \(error)")
//                        }
//                    } catch {
//                        // TODO: Handle Errors if Necessary
//                        print("Error ensuring authToken in ConversationAttachmentsView, continuing... \(error)")
//                    }
                }
            }
        }
        .onChange(of: pdfAttachment) { newValue in
            Task {
                // If persistentAttachment can be unwrapped the pdf was attached successfully
                if let persistentAttachment = newValue {
                    // Update persistentAttachment with conversation
                    do {
                        try await PersistentAttachmentCDHelper.update(persistentAttachment, conversation: conversation, in: viewContext)
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error updating persistentAttachment's conversation in ConversationAttachmentsView... \(error)")
                        await MainActor.run {
                            alertShowingErrorAttaching = true
                        }
                    }
                    
                    // Remove Assistant text from behavior TODO: This should definitely be done somewhere else or Assistants should be handled better, like copying over important data to a separate object and then being able to control the Assistant's prompt independently like that, but for the time being it needs to be done for all of the attachments
                    do {
                        try await ConversationCDHelper.removeAssistantTextFromBehavior(
                            for: conversation,
                            in: viewContext)
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error removing assistant text from behavior in AttachmentsView... \(error)")
                        await MainActor.run {
                            alertShowingErrorAttaching = true
                        }
                    }
                    
                    // Generate attachment summary by generating blank and removing first chat if necessary
                    doGenerateBlankRemoveFirstChatIfInConversation = true
//                    do {
//                        // Ensure unwrap authToken
//                        let authToken = try await AuthHelper.ensure()
//                        
//                        // Generate attachment summary by generating blank and removing first chat if necessary
//                        do {
//                            try await conversationChatGenerator.generateBlankRemoveFirstChatIfInConversation(
//                                authToken: authToken,
//                                conversation: conversation,
//                                isPremium: premiumUpdater.isPremium,
//                                model: GPTModelHelper.currentChatModel,
//                                in: viewContext)
//                        } catch {
//                            // TODO: Handle Errors if Necessary
//                            print("Error generating blank removing first chat if in conversation in ConversationAttachmentsView, continuing... \(error)")
//                        }
//                    } catch {
//                        // TODO: Handle Errors if Necessary
//                        print("Error ensuring authToken in ConversationAttachmentsView, continuing... \(error)")
//                    }
                }
            }
        }
        .onChange(of: voiceAttachment) { newValue in
            Task {
                // If persistentAttachment can be unwrapped the voice was attached successfully
                if let persistentAttachment = newValue {
                    // Update persistentAttachment with conversation
                    do {
                        try await PersistentAttachmentCDHelper.update(persistentAttachment, conversation: conversation, in: viewContext)
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error updating persistentAttachment's conversation in ConversationAttachmentsView... \(error)")
                        await MainActor.run {
                            alertShowingErrorAttaching = true
                        }
                    }
                    
                    // Remove Assistant text from behavior TODO: This should definitely be done somewhere else or Assistants should be handled better, like copying over important data to a separate object and then being able to control the Assistant's prompt independently like that, but for the time being it needs to be done for all of the attachments
                    do {
                        try await ConversationCDHelper.removeAssistantTextFromBehavior(
                            for: conversation,
                            in: viewContext)
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error removing assistant text from behavior in AttachmentsView... \(error)")
                        await MainActor.run {
                            alertShowingErrorAttaching = true
                        }
                    }
                    
                    // Generate attachment summary by generating blank and removing first chat if necessary
                    doGenerateBlankRemoveFirstChatIfInConversation = true
//                    do {
//                        // Ensure unwrap authToken
//                        let authToken = try await AuthHelper.ensure()
//                        
//                        // Generate attachment summary by generating blank and removing first chat if necessary
//                        do {
//                            try await conversationChatGenerator.generateBlankRemoveFirstChatIfInConversation(
//                                authToken: authToken,
//                                conversation: conversation,
//                                isPremium: premiumUpdater.isPremium,
//                                model: GPTModelHelper.currentChatModel,
//                                in: viewContext)
//                        } catch {
//                            // TODO: Handle Errors if Necessary
//                            print("Error generating blank removing first chat if in conversation in ConversationAttachmentsView, continuing... \(error)")
//                        }
//                    } catch {
//                        // TODO: Handle Errors if Necessary
//                        print("Error ensuring authToken in ConversationAttachmentsView, continuing... \(error)")
//                    }
                }
            }
        }
        .onChange(of: webpageAttachment) { newValue in
            Task {
                // If persistentAttachment can be unwrapped the webpage was attached successfully
                if let persistentAttachment = newValue {
                    // Update persistentAttachment with conversation
                    do {
                        try await PersistentAttachmentCDHelper.update(persistentAttachment, conversation: conversation, in: viewContext)
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error updating persistentAttachment's conversation in ConversationAttachmentsView... \(error)")
                        await MainActor.run {
                            alertShowingErrorAttaching = true
                        }
                    }
                    
                    // Remove Assistant text from behavior TODO: This should definitely be done somewhere else or Assistants should be handled better, like copying over important data to a separate object and then being able to control the Assistant's prompt independently like that, but for the time being it needs to be done for all of the attachments
                    do {
                        try await ConversationCDHelper.removeAssistantTextFromBehavior(
                            for: conversation,
                            in: viewContext)
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error removing assistant text from behavior in AttachmentsView... \(error)")
                        await MainActor.run {
                            alertShowingErrorAttaching = true
                        }
                    }
                    
                    // Generate attachment summary by generating blank and removing first chat if necessary
                    doGenerateBlankRemoveFirstChatIfInConversation = true
//                    do {
//                        // Ensure unwrap authToken
//                        let authToken = try await AuthHelper.ensure()
//                        
//                        // Generate attachment summary by generating blank and removing first chat if necessary
//                        do {
//                            try await conversationChatGenerator.generateBlankRemoveFirstChatIfInConversation(
//                                authToken: authToken,
//                                conversation: conversation,
//                                isPremium: premiumUpdater.isPremium,
//                                model: GPTModelHelper.currentChatModel,
//                                in: viewContext)
//                        } catch {
//                            // TODO: Handle Errors if Necessary
//                            print("Error generating blank removing first chat if in conversation in ConversationAttachmentsView, continuing... \(error)")
//                        }
//                    } catch {
//                        // TODO: Handle Errors if Necessary
//                        print("Error ensuring authToken in ConversationAttachmentsView, continuing... \(error)")
//                    }
                }
            }
        }
        .alert("Error Attatching", isPresented: $alertShowingErrorAttaching, actions: {
            Button("Close", action: {
                
            })
        }) {
            Text("There was an error attaching your file. Please try again.")
        }
    }
    
//    private func read(from url: URL) -> String? {
//        let accessing = url.startAccessingSecurityScopedResource()
//        defer {
//            if accessing {
//                url.stopAccessingSecurityScopedResource()
//            }
//        }
//
//        do {
//            return try String(contentsOf: url)
//        } catch {
//            // If couldn't from String, try getting as a PDF
//            print("Could not get as String, trying as PDF...")
//        }
//
//        if let pdf = PDFDocument(url: url) {
//            let pageCount = pdf.pageCount
//            let content = NSMutableAttributedString()
//
//            for i in 0..<pageCount {
//                // Get page, otherwise continue
//                guard let page = pdf.page(at: i) else {
//                    continue
//                }
//
//                // Get pageContent, otherwise continue
//                guard let pageContent = page.attributedString else {
//                    continue
//                }
//
//                // Append pageContent to content
//                content.append(pageContent)
//            }
//
//            return content.string
//        }
//
//        return nil
//    }
    
}

//#Preview {
//    
//    VStack {
//        Spacer()
//        
//        HStack {
//            Spacer()
//            
//            let conversation: Conversation = {
//                return CDClient.mainManagedObjectContext.performAndWait {
//                    let fetchRequest = Conversation.fetchRequest()
//                    fetchRequest.fetchLimit = 1
//                    
//                    return try! CDClient.mainManagedObjectContext.fetch(fetchRequest)[0]
//                }
//            }()
//            
//            ConversationAttachmentsView(
//                conversation: conversation,
//                doGenerateBlankRemoveFirstChatIfInConversation: .constant(false))
//            .padding()
//            .background(Colors.background)
//            
//            Spacer()
//        }
//        
//        Spacer()
//    }
//    .environmentObject(PremiumUpdater())
//    
//}
//
