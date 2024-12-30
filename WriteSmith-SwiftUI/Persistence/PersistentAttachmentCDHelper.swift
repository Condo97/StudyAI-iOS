//
//  PersistentAttachmentCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import CoreData
import Foundation

class PersistentAttachmentCDHelper {
    
    @discardableResult
    static func create(type: AttachmentType, documentsFilePath: String, cachedText: String?, in managedContext: NSManagedObjectContext) async throws -> PersistentAttachment {
        try await managedContext.perform {
            let persistentAttachment = PersistentAttachment(context: managedContext)
            persistentAttachment.attachmentType = type.rawValue
            persistentAttachment.documentsFilePath = documentsFilePath
            persistentAttachment.cachedText = cachedText
            persistentAttachment.date = Date()
            
            try managedContext.save()
            
            return persistentAttachment
        }
    }
    
    @discardableResult
    static func createFlashCardsAttachment(to flashCardCollection: FlashCardCollection, in managedContext: NSManagedObjectContext) async throws -> PersistentAttachment {
        try await managedContext.perform {
            let persistentAttachment = PersistentAttachment(context: managedContext)
            persistentAttachment.attachmentType = AttachmentType.flashcards.rawValue
            persistentAttachment.flashCardCollection = flashCardCollection
//            persistentAttachment.conversation = conversation
            persistentAttachment.date = Date()
            
            try managedContext.save()
            
            return persistentAttachment
        }
    }
    
    @discardableResult
    static func createWebsiteAttachment(externalURL: URL, cachedText: String?, in managedContext: NSManagedObjectContext) async throws -> PersistentAttachment {
        try await managedContext.perform {
            let persistentAttachment = PersistentAttachment(context: managedContext)
            persistentAttachment.attachmentType = AttachmentType.webUrl.rawValue
            persistentAttachment.externalURL = externalURL
            persistentAttachment.cachedText = cachedText
            persistentAttachment.date = Date()
            
            try managedContext.save()
            
            return persistentAttachment
        }
    }
    
    static func delete(_ persistentAttachment: PersistentAttachment, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            managedContext.delete(persistentAttachment)
            
            try managedContext.save()
        }
    }
    
    static func update(_ persistentAttachment: PersistentAttachment, cachedText: String, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            persistentAttachment.cachedText = cachedText
            
            try managedContext.save()
        }
    }
    
    static func update(_ persistentAttachment: PersistentAttachment, conversation: Conversation, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            persistentAttachment.conversation = conversation
            
            try managedContext.save()
        }
    }
    
    static func update(_ persistentAttachment: PersistentAttachment, flashCardCollection: FlashCardCollection, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            persistentAttachment.flashCardCollection = flashCardCollection
            
            try managedContext.save()
        }
    }
    
    static func update(_ persistentAttachment: PersistentAttachment, generatedTitle: String, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            persistentAttachment.generatedTitle = generatedTitle
            
            try managedContext.save()
        }
    }
    
    static func update(_ persistentAttachment: PersistentAttachment, panelComponentContent: PanelComponentContent, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            persistentAttachment.panelComponentContent = panelComponentContent
            
            try managedContext.save()
        }
    }
    
}
