//
//  AttachPDFView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import PDFKit
import SwiftUI

struct AttachPDFButton: View {
    
    @Binding var pdfDocumentsFilepath: String?
    var subtitle: LocalizedStringKey// = "Add a PDF or text doc. Send an assignment to ask questions."
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isShowingFileImporter: Bool = false
    
    @State private var alertShowingErrorAttachingPdf: Bool = false
    @State private var alertShowingErrorReading: Bool = false
    
    @State private var attachedPdfURL: URL?
    
    var body: some View {
        Button(action: {
            isShowingFileImporter = true
        }) {
            VStack(alignment: .leading) {
                HStack {
//                    Text(Image(systemName: "doc.text"))
                    Text("📄")
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        .padding(4)
                        .frame(width: 38.0, height: 38.0)
                        .background(Colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                
                    Text("PDF")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                HStack {
                    Text(subtitle)
                        .font(.custom(Constants.FontName.body, size: 10.0))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .alert("Couldn't Read File", isPresented: $alertShowingErrorReading, actions: {
            Button("Close", action: {
                
            })
        }) {
            Text("Please save the file as a PDF or txt and try again.")
        }
        .onChange(of: attachedPdfURL) { newValue in
            // Ensure unwrap pdf or text url, otherwise show alert
            guard let newValue = newValue else {
                alertShowingErrorAttachingPdf = true
                return
            }
            
            // Save to documents directory
            let newFileName: String
            do {
                newFileName = try DocumentSaver.saveSecurityScopedFileToDocumentsDirectory(from: newValue)
            } catch {
                // Show error alert and return
                print("Error saving PDF or text to DocumentSvaer in AttachmentsView... \(error)")
                alertShowingErrorAttachingPdf = true
                return
            }
            
            // Set pdfDocumentsFilepath to newFileName
            self.pdfDocumentsFilepath = newFileName
        }
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.pdf, .text],
            onCompletion: { result in
                // Get resultUrl for the file's url from result
                let resultUrl = try? result.get()
                
                // Set attachedPdfURL to resultUrl
                self.attachedPdfURL = resultUrl
            })
        .alert("Error Attatching PDF", isPresented: $alertShowingErrorAttachingPdf, actions: {
            Button("Close", action: {
                
            })
        }) {
            Text("There was an error attaching your pdf or text file. Please try again.")
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
//    ZStack {
//        VStack {
//            Spacer()
//            
//            HStack {
//                Spacer()
//                
//                AttachPDFButton(
//                    pdfDocumentsFilepath: .constant(nil),
//                    subtitle: "Add a PDF or text doc. Send an assignment to ask questions.")
//                    .foregroundStyle(Colors.text)
//                    .padding()
//                    .background(Colors.foreground)
//                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                
//                Spacer()
//            }
//            
//            Spacer()
//        }
//    }
//    .background(Colors.background)
//    
//}
