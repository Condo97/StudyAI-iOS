//
//  FileToText.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import Foundation
import PDFKit

class FileToText {
    
    static func pdfOrText(data: Data) -> String? {
        // If data is String, return it TODO: I think this will always trigger, there should be a better solution I think
        if let dataAsString = String(data: data, encoding: .utf8) {
            return dataAsString
        }
        
        guard let pdf = PDFDocument(data: data) else {
            // TODO: Handle Errors if Necessary
            return nil
        }
        
        let pageCount = pdf.pageCount
        let content = NSMutableAttributedString()
        
        for i in 0..<pageCount {
            // Get page, otherwise continue
            guard let page = pdf.page(at: i) else {
                continue
            }
            
            // Get pageContent, otherwise continue
            guard let pageContent = page.attributedString else {
                continue
            }
            
            // Append pageContent to content
            content.append(pageContent)
        }
        
        return content.string
    }
    
}
