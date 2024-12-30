//
//  PersistentAttachmentNetworkedPersistenceManager.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/15/24.
//

import CoreData
import Foundation
import PDFKit
import WebKit

// TODO: This should be moved to a different folder since it basically combines Persistence and Networking
class PersistentAttachmentNetworkedPersistenceManager {
    
    static func createUpdateCachedTextAndGeneratedTitle(type: AttachmentType, documentsFilePath: String, in managedContext: NSManagedObjectContext) async throws -> PersistentAttachment {
        let persistentAttachment = try await PersistentAttachmentCDHelper.create(
            type: type,
            documentsFilePath: documentsFilePath,
            cachedText: nil,
            in: managedContext)
        
        if type == .image {
            try await generateAndUpdateGeneratedTitleFromImage(
                for: persistentAttachment,
                in: managedContext)
        } else {
            try await updateCachedText(
                for: persistentAttachment,
                in: managedContext)
            
            try await generateAndUpdateGeneratedTitleFromCachedText(
                for: persistentAttachment,
                in: managedContext)
        }
        
        return persistentAttachment
    }
    
    static func createFlashCardsAttachmentUpdateCachedTextAndGeneratedTitle(flashCardCollection: FlashCardCollection, title: String?, in managedContext: NSManagedObjectContext) async throws -> PersistentAttachment {
        let persistentAttachment = try await PersistentAttachmentCDHelper.createFlashCardsAttachment(
            to: flashCardCollection,
            in: managedContext)
        
        try await updateCachedText(
            for: persistentAttachment,
            in: managedContext)
        
        if let title = title {
            // Set and save title as generatedTitle in persistentAttachment
            try await PersistentAttachmentCDHelper.update(persistentAttachment, generatedTitle: title, in: managedContext)
        } else {
            try await generateAndUpdateGeneratedTitleFromCachedText(
                for: persistentAttachment,
                in: managedContext)
        }
        
        return persistentAttachment
    }
    
    static func createWebsiteAttachmentUpdateCachedTextAndGeneratedTitle(externalURL: URL, in managedContext: NSManagedObjectContext) async throws -> PersistentAttachment {
        let persistentAttachment = try await PersistentAttachmentCDHelper.createWebsiteAttachment(
            externalURL: externalURL,
            cachedText: nil,
            in: managedContext)
        
        try await updateCachedText(
            for: persistentAttachment,
            in: managedContext)
        
        try await generateAndUpdateGeneratedTitleFromCachedText(
            for: persistentAttachment,
            in: managedContext)
        
        return persistentAttachment
    }
    
//    static func updateCachedTextAndGeneratedTitle(for persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
//        // Get and unwrap attachmentType, otherwise return
//        guard let attachmentTypeString = persistentAttachment.attachmentType,
//              let attachmentType = AttachmentType(rawValue:  attachmentTypeString) else {
//            // TODO: Handle Errors
//            print("Could not unwrap attachmentType from persistent attachment in PersistentAttachmentNetworkedPersistenceManager!")
//            return
//        }
//        
//        // Update the cache correctly for the attachmentType
//        switch attachmentType {
//        case .flashcards:
//            // TODO: Implement ..and title from cachedText
//            try await updateFlashcardsCachedText(for: persistentAttachment, in: managedContext)
//            try await generateAndUpdateGeneratedTitleFromCachedText(
//                for: persistentAttachment,
//                in: managedContext)
//        case .image:
//            // No update necessary TODO: Is it a good idea to return here, like is it a good implementation, since it doens't need to generate a title?
//            break
//        case .pdfOrText:
//            // Haven't implemented and title from cachedText
//            try await updatePdfCachedText(for: persistentAttachment, in: managedContext)
//            try await generateAndUpdateGeneratedTitleFromCachedText(
//                for: persistentAttachment,
//                in: managedContext)
//        case .voice:
//            // Update cached text for voice and title from cachedText
//            try await updateVoiceCachedText(for: persistentAttachment, in: managedContext)
//            try await generateAndUpdateGeneratedTitleFromCachedText(
//                for: persistentAttachment,
//                in: managedContext)
//        case .webUrl:
//            // Update cached text for URL and title from cachedText
//            try await updateURLCachedText(for: persistentAttachment, in: managedContext)
//            try await generateAndUpdateGeneratedTitleFromCachedText(
//                for: persistentAttachment,
//                in: managedContext)
//            
//        }
//        
////        try await generateAndUpdateGeneratedTitleFromCachedText(
////            for: persistentAttachment,
////            in: managedContext)
//    }
    
    static func updateCachedText(for persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
        // Get and unwrap attachmentType, otherwise return
        guard let attachmentTypeString = persistentAttachment.attachmentType,
              let attachmentType = AttachmentType(rawValue:  attachmentTypeString) else {
            // TODO: Handle Errors
            print("Could not unwrap attachmentType from persistent attachment in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Update the cache correctly for the attachmentType
        switch attachmentType {
        case .flashcards:
            // TODO: Implement ..and title from cachedText
            try await updateFlashcardsCachedText(for: persistentAttachment, in: managedContext)
        case .image:
            // No update necessary TODO: Is it a good idea to return here, like is it a good implementation, since it doens't need to generate a title?
            break
        case .pdfOrText:
            // Haven't implemented and title from cachedText
            try await updatePdfCachedText(for: persistentAttachment, in: managedContext)
        case .voice:
            // Update cached text for voice and title from cachedText
            try await updateVoiceCachedText(for: persistentAttachment, in: managedContext)
        case .webUrl:
            // Update cached text for URL and title from cachedText
            try await updateURLCachedText(for: persistentAttachment, in: managedContext)
        }
    }
    
    static func generateAndUpdateGeneratedTitleFromCachedText(for persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap cachedText, otherwise return
        guard let cachedText = persistentAttachment.cachedText else {
            // TODO: Handle Errors, should probably throw
            return
        }
        
        // Ensure and unwrap authToken TODO: This should be done by the caller
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            print("Error ensuring authToken in SuggestionsView... \(error)")
            throw error
        }
        
        // Create GenerateTitleRequest
        let generateTitleRequest = GenerateTitleRequest(
            authToken: authToken,
            input: cachedText,
            imageData: nil)
        
        // Get GenerateTitleResponse with ChitChatHTTPSConnector
        let generateTitleResponse = try await ChitChatHTTPSConnector.generateTitle(request: generateTitleRequest)
        
        // Ensure unwrap title, otherwise return
        guard let title = generateTitleResponse.body.title else {
            // TODO: Handle Errors, should probably throw
            return
        }
        
        // Set and save title as generatedTitle in persistentAttachment
        try await PersistentAttachmentCDHelper.update(persistentAttachment, generatedTitle: title, in: managedContext)
    }
    
    static func generateAndUpdateGeneratedTitleFromImage(for persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap persistent attachment documents file path and image data
        guard let documentsFilePath = persistentAttachment.documentsFilePath,
              let imageData = try DocumentSaver.getData(from: documentsFilePath) else {
            // TODO: Handle Errors
            return
        }
        
        // Ensure and unwrap authToken TODO: This should be done by the caller
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            print("Error ensuring authToken in SuggestionsView... \(error)")
            throw error
        }
        
        // Create GenerateTitleRequest
        let generateTitleRequest = GenerateTitleRequest(
            authToken: authToken,
            input: nil,
            imageData: imageData.base64EncodedString())
        
        // Get GenerateTitleResponse with ChitChatHTTPSConnector
        let generateTitleResponse = try await ChitChatHTTPSConnector.generateTitle(request: generateTitleRequest)
        
        // Ensure unwrap title, otherwise return
        guard let title = generateTitleResponse.body.title else {
            // TODO: Handle Errors, should probably throw
            return
        }
        
        // Set and save title as generatedTitle in persistentAttachment
        try await managedContext.perform {
            persistentAttachment.generatedTitle = title
            
            try managedContext.save()
        }
    }
    
    // MARK: - PDF Cache Updating
    
    private static func updateFlashcardsCachedText(for persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap flashCardCollection from persistentAttachment
        guard let flashCardCollection = persistentAttachment.flashCardCollection else {
            // TODO: Handle Errors if Necessary
            print("Could not unwrap flash card collection from persistent attachment in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Get cachedText
        guard let cachedText = try await AttachmentAdapter.getFlashCardCollectionCachedText(from: flashCardCollection, in: managedContext) else {
            // TODO: Handle Errors if Nececssary
            print("Could not unwrap cachedText in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Update cachedText to persistentAttachment
        try await PersistentAttachmentCDHelper.update(persistentAttachment, cachedText: cachedText, in: managedContext)
    }
    
    private static func updatePdfCachedText(for persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap persistentAttachment documentsFilePath, otherwise return
        guard let persistentAttachmentDocumentsFilepath = persistentAttachment.documentsFilePath else {
            // TODO: Handle Errors if Necessary
            print("Could not unwrap documents filepath for persistent attachment in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Get cachedText
        guard let cachedText = try AttachmentAdapter.getPDFCachedText(from: persistentAttachmentDocumentsFilepath) else {
            // TODO: Handle Errors if Necessary
            print("Could not unwrap cachedText in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Update cachedText to persistentAttachment
        try await PersistentAttachmentCDHelper.update(persistentAttachment, cachedText: cachedText, in: managedContext)
    }
    
    // MARK: - Voice Cache Updating
    
    private static func updateVoiceCachedText(for persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap persistentAttachment documentsFilePath, otherwise return
        guard let persistentAttachmentDocumentsFilepath = persistentAttachment.documentsFilePath else {
            // TODO: Handle Errors if Necessary
            print("Could not unwrap documents filepath for persistent attachment in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Get and unwrap cachedText
        guard let cachedText = try await AttachmentAdapter.getVoiceCachedText(from: persistentAttachmentDocumentsFilepath) else {
            // TODO: Handle Errors if Necessary
            print("Could not unwrap cachedText in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Update cachedText to persistentAttachment
        try await PersistentAttachmentCDHelper.update(persistentAttachment, cachedText: cachedText, in: managedContext)
    }
    
    // MARK: - URL Cache Updating
    
    private static func updateURLCachedText(for persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap persistentAttachment externalURL, otherwise return
        guard let persistentAttachmentExternalURL = persistentAttachment.externalURL else {
            // TODO: Handle Errors if Necessary
            print("Could not unwrap externalURL for persistent attachment in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Get and unwrap cachedText
        guard let cachedText = try await AttachmentAdapter.getURLCachedText(from: persistentAttachmentExternalURL) else {
            // TODO: Handle Errors if Necessary
            print("Could not unwrap cachedText in PersistentAttachmentNetworkedPersistenceManager!")
            return
        }
        
        // Update cachedText to persistentAttachment
        try await PersistentAttachmentCDHelper.update(persistentAttachment, cachedText: cachedText, in: managedContext)
    }
    
}
