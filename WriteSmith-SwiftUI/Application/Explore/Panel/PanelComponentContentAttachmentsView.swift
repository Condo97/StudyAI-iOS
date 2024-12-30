////
////  PanelComponentContentAttachmentsView.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 4/14/24.
////
//
//import CoreData
//import PDFKit
//import SwiftUI
//
//struct PanelComponentContentAttachmentsView: View {
//    
//    @Binding var panelComponentContent: PanelComponentContent
//    
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    @State private var imageAttachment: PersistentAttachment?
//    @State private var pdfAttachment: PersistentAttachment?
//    @State private var voiceAttachment: PersistentAttachment?
//    @State private var webpageAttachment: PersistentAttachment?
//    
//    @State private var alertShowingErrorAttaching: Bool = false
//    
//    
//    var body: some View {
//        AttachmentsView(
//            imageAttachment: $imageAttachment,
//            pdfAttachment: $pdfAttachment,
//            voiceAttachment: $voiceAttachment,
//            webpageAttachment: $webpageAttachment)
//        .onChange(of: imageAttachment) { newValue in
//            // If persistentAttachment can be unwrapped the image was attached successfully
//            if let persistentAttachment = newValue {
//                // Update persistentAttachment with panelComponentContent
//                do {
//                    try PersistentAttachmentCDHelper.update(persistentAttachment, panelComponentContent: panelComponentContent, in: viewContext)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error updating persistentAttachment's panelComponentContent in PanelComponentContentAttachmentsView... \(error)")
//                    alertShowingErrorAttaching = true
//                }
//            }
//        }
//        .onChange(of: pdfAttachment) { newValue in
//            // If persistentAttachment can be unwrapped the pdf was attached successfully
//            if let persistentAttachment = newValue {
//                // Update persistentAttachment with panelComponentContent
//                do {
//                    try PersistentAttachmentCDHelper.update(persistentAttachment, panelComponentContent: panelComponentContent, in: viewContext)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error updating persistentAttachment's panelComponentContent in PanelComponentContentAttachmentsView... \(error)")
//                    alertShowingErrorAttaching = true
//                }
//            }
//        }
//        .onChange(of: voiceAttachment) { newValue in
//            // If persistentAttachment can be unwrapped the voice was attached successfully
//            if let persistentAttachment = newValue {
//                // Update persistentAttachment with panelComponentContent
//                do {
//                    try PersistentAttachmentCDHelper.update(persistentAttachment, panelComponentContent: panelComponentContent, in: viewContext)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error updating persistentAttachment's panelComponentContent in PanelComponentContentAttachmentsView... \(error)")
//                    alertShowingErrorAttaching = true
//                }
//            }
//        }
//        .onChange(of: webpageAttachment) { newValue in
//            // If persistentAttachment can be unwrapped the webpage was attached successfully
//            if let persistentAttachment = newValue {
//                // Update persistentAttachment with panelComponentContent
//                do {
//                    try PersistentAttachmentCDHelper.update(persistentAttachment, panelComponentContent: panelComponentContent, in: viewContext)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error updating persistentAttachment's panelComponentContent in PanelComponentContentAttachmentsView... \(error)")
//                    alertShowingErrorAttaching = true
//                }
//            }
//        }
//        .alert("Error Attatching", isPresented: $alertShowingErrorAttaching, actions: {
//            Button("Close", action: {
//                
//            })
//        }) {
//            Text("There was an error attaching your file. Please try again.")
//        }
//    }
//    
//}
//
//#Preview {
//    VStack {
//        Spacer()
//        
//        HStack {
//            Spacer()
//            
//            let panelComponentContent: PanelComponentContent = {
//                return try! CDClient.mainManagedObjectContext.performAndWait {
//                    let panelComponentContent = PanelComponentContent(context: CDClient.mainManagedObjectContext)
//                    panelComponentContent.cachedInput = "Cached input"
//                    
//                    try CDClient.mainManagedObjectContext.save()
//                    
//                    return panelComponentContent
//                }
//            }()
//            
//            PanelComponentContentAttachmentsView(
//                panelComponentContent: .constant(panelComponentContent))
//            .padding()
//            .background(Colors.background)
//            
//            Spacer()
//        }
//        
//        Spacer()
//    }
//}
//
//
