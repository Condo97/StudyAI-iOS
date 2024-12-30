//
//  AttachmentAdapter.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import CoreData
import Foundation
import PDFKit

class AttachmentAdapter {
    
    static func getFlashCardCollectionCachedText(from flashCardCollection: FlashCardCollection, in managedContext: NSManagedObjectContext) async throws -> String? {
        try await compileFlashCardCollectionToString(flashCardCollection: flashCardCollection, in: managedContext)
    }
    
    static func getPDFCachedText(from documentsFilepath: String) throws -> String? {
        // Get and unwrap cachedText
        try readPDFOrText(pdfDocumentsPath: documentsFilepath)
    }
    
    static func getVoiceCachedText(from documentsFilepath: String) async throws -> String? {
        try await getVoiceTranscription(voiceDocumentsPath: documentsFilepath)
    }
    
    static func getURLCachedText(from url: URL) async throws -> String? {
        try await WebpageTextReader.getWebpageText(externalURL: url)
    }
    
    
    private static func compileFlashCardCollectionToString(flashCardCollection: FlashCardCollection, in managedContext: NSManagedObjectContext) async throws -> String? {
        let indexString = "Index: "
        let frontString = "Front: "
        let backString = "Back: "
        let commaSpaceString = ", "
        
        let fetchRequest = FlashCard.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(FlashCard.flashCardCollection), flashCardCollection)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FlashCard.index), ascending: true)]
        
        return try await managedContext.perform {
            let flashCards = try managedContext.fetch(fetchRequest)
            
            return flashCards.compactMap({
                if let front = $0.front,
                   let back = $0.back {
                    return indexString + "\($0.index)" + commaSpaceString + frontString + front + commaSpaceString + backString + back
                }
                
                return nil
            }).joined(separator: "\n")
        }
    }
    
    private static func getVoiceTranscription(voiceDocumentsPath: String) async throws -> String? {
        // Ensure unwrap voiceData from DocumentSaver, otherwise return
        guard let voiceData = try DocumentSaver.getData(from: voiceDocumentsPath) else {
            // TODO: Handle Errors
            print("Could not unwrap voiceData from voiceDocumentsPath with DocumentSaver in PersistentAttachmentNetworkedPersistenceManager!")
            return nil
        }
        
        // Ensure and unwrap authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            print("Error ensuring authToken in SuggestionsView... \(error)")
            throw error
        }
        
        // Build TranscribeSpeechRequest
        let transcribeSpeechRequest = TranscribeSpeechRequest(
            authToken: authToken,
            speechFileName: voiceDocumentsPath,
            speechFile: voiceData)
        
        // Get transcribeSpeechResponse
        let transcribeSpeechResponse = try await ChitChatHTTPSConnector.transcribeSpeech(request: transcribeSpeechRequest)
        
        // Ensure unwrap liveTranscribedText from transcribeSpeechResponse body, otherwise return nil
        guard let transcribedText = transcribeSpeechResponse.body.text else {
            return nil
        }
        
        // Return liveTranscribedText trimmed for use with gpt
        return String(transcribedText.prefix(3000))
    }
    
    private static func readPDFOrText(pdfDocumentsPath: String) throws -> String? {
        // Ensure unwrap voiceData from DocumentSaver, otherwise return
        guard let pdfData = try DocumentSaver.getData(from: pdfDocumentsPath) else {
            // TODO: Handle Errors
            print("Could not unwrap voiceData from voiceDocumentsPath with DocumentSaver in PersistentAttachmentNetworkedPersistenceManager!")
            return nil
        }
        
        // Return readPDFOrText from pdfData
        return readPDFOrText(from: pdfData)
    }
    
    private static func readPDFOrText(from data: Data) -> String? {
        // If text can be directly decoded from data return it TODO: Is this a good implementation?
        if let readText = String(data: data, encoding: .utf8) {
            return readText
        }
        
        if let pdf = PDFDocument(data: data) {
            return PDFReader.readPDF(from: pdf)
        }
        
        return nil
    }
    
}
