////
////  ConversationDrawerGenerator.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 4/19/24.
////
//
//import CoreData
//import Foundation
//
//class ConversationDrawerGenerator: DrawerGenerator {
//    
//    func generateDrawerCollection(inputText: String, inputImageData: Data?, sender: Sender, chatText: String?, authToken: String, in conversation: Conversation, to managedContext: NSManagedObjectContext) async throws -> Chat {
//        // Generate drawer collection
//        let generatedDrawerCollection = try await generateDrawerCollection(
//            text: inputText,
//            imageData: inputImageData,
//            authToken: authToken,
//            in: managedContext)
//        
//        // Create and return Chat in Conversation including generatedDrawerCollection with ChatCDHelper
//        let chat = try await ChatCDHelper.appendChat(
//            sender: sender,
//            text: chatText,
//            drawerCollection: generatedDrawerCollection,
//            to: conversation,
//            in: managedContext)
//        
//        return chat
//    }
//    
//}
