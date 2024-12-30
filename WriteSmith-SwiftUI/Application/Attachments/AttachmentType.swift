//
//  AttachmentType.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import Foundation
import UniformTypeIdentifiers

enum AttachmentType: String {
    
    case flashcards = "flashcards"
    case image = "image"
    case pdfOrText = "pdfOrText"
    case voice = "voice"
    case webUrl = "webUrl"
    
}

extension AttachmentType {
    
    static func from(url: URL) -> AttachmentType {
        // Attempt to get the Uniform Type Identifier (UTI) from the URL
        if let utType = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType {
            return attachmentType(for: utType)
        } else {
            // If unable to get UTI from URL (e.g., for remote URLs), fallback to using the file extension
            let ext = url.pathExtension.lowercased()
            if let utType = UTType(filenameExtension: ext) {
                return attachmentType(for: utType)
            } else {
                return .pdfOrText // Default to pdfOrText if the type is unknown
            }
        }
    }
    
    // Helper function to determine AttachmentType from UTType
    private static func attachmentType(for utType: UTType) -> AttachmentType {
        if utType.conforms(to: .image) {
            return .image
        } else if utType.conforms(to: .audio) {
            return .voice
        } else if utType.conforms(to: .pdf) || utType.conforms(to: .plainText) || utType.conforms(to: .rtf) || utType.conforms(to: .text) || utType.conforms(to: .xml) || utType.conforms(to: .html) || utType.conforms(to: .spreadsheet) || utType.conforms(to: .commaSeparatedText) {
            return .pdfOrText
        } else if utType.conforms(to: .url) {
            return .webUrl
        } else {
            return .pdfOrText // Default to pdfOrText if no matches are found
        }
        
        // TODO: Flashcards ?
    }
    
}
