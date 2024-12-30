//
//  AttachmentsContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct AttachmentsContainer: View {
    
    var allowedAttachmentTypes: [AttachmentType] = [.image, .pdfOrText, .webUrl, .voice]
    var displayStyle: AttachmentsView.DisplayStyle
    @Binding var imageAttachment: PersistentAttachment?
    @Binding var pdfAttachment: PersistentAttachment?
    @Binding var voiceAttachment: PersistentAttachment?
    @Binding var webpageAttachment: PersistentAttachment?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var imageDocumentsFilepath: String?
    @State private var pdfDocumentsFilepath: String?
    @State private var voiceDocumentsFilepath: String?
    @State private var attachedWebUrl: URL?
    
    @State private var isLoading: Bool = false
    
    @State private var alertShowingErrorAttaching: Bool = false
    
    var body: some View {
        AttachmentsView(
            allowedAttachmentTypes: allowedAttachmentTypes,
            displayStyle: displayStyle,
            imageDocumentsFilepath: $imageDocumentsFilepath,
            pdfDocumentsFilepath: $pdfDocumentsFilepath,
            voiceDocumentsFilepath: $voiceDocumentsFilepath,
            attachedWebUrl: $attachedWebUrl)
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
        .overlay {
            if isLoading {
                ZStack {
                    Colors.foreground
                        .opacity(0.4)
                    
                    ProgressView()
                        .tint(Colors.elementTextColor)
                }
            }
        }
        .onChange(of: imageDocumentsFilepath) { newValue in
            // Ensure unwrap newValue, otherwise return TODO: Make sure all errors with setting newValue are handled before this, since this should not do anything if newValue is set to false
            guard let newValue = newValue else {
                return
            }
            
            Task {
                // Defer setting isLoading to false
                defer {
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
                
                // Set isLoading to true
                DispatchQueue.main.async {
                    isLoading = true
                }
                
                // Create persistent attachment
                let persistentAttachment: PersistentAttachment
                do {
                    persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
                        type: .image,
                        documentsFilePath: newValue,
                        in: viewContext)
                    //                try PersistentAttachmentCDHelper.create(
                    //                    type: .image,
                    //                    documentsFilePath: newValue,
                    //                    cachedText: nil,
                    //                    in: viewContext)
                } catch {
                    // TODO: Handle Errors if Necessary
                    print("Error creating PersistentAttachment in AttachmentsView... \(error)")
                    alertShowingErrorAttaching = true
                    return
                }
                
//                // Generate and update generated title from image for persistentAttachment TODO: Make the image get a title based on the image
//                Task {
//                    if let imagePNGData = try DocumentSaver.getImage(from: newValue)?.pngData(),
//                       let imageResizedJPEGData = ImageResizer.resizedJpegDataTo512(from: imagePNGData) {
//                        do {
//                            try await PersistentAttachmentNetworkedPersistenceManager.generateAndUpdateGeneratedTitleFromImage(
//                                imageData: imageResizedJPEGData,
//                                for: persistentAttachment,
//                                in: viewContext)
//                        } catch {
//                            // TODO: Handle Errors if Necessary
//                            print("Error generating and updating generated title from cached text in AttachmentsView... \(error)")
//                        }
//                    }
//                }
                
                // Set image attachment to persistent attachment
                await MainActor.run {
                    imageAttachment = persistentAttachment
                }
            }
        }
        .onChange(of: pdfDocumentsFilepath) { newValue in
            // Ensure unwrap newValue, otherwise return TODO: Make sure all errors with setting newValue are handled before this, since this should not do anything if newValue is set to false
            guard let newValue = newValue else {
                return
            }
            
            Task {
                // Defer setting isLoading to false
                defer {
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
                
                // Set isLoading to true
                DispatchQueue.main.async {
                    isLoading = true
                }
                
                // Create persistent attachment
                let persistentAttachment: PersistentAttachment
                do {
                    persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
                        type: .pdfOrText,
                        documentsFilePath: newValue,
                        in: viewContext)
                } catch {
                    // TODO: Handle Errors if Necessary
                    print("Error creating PersistentAttachment in AttachmentsView... \(error)")
                    alertShowingErrorAttaching = true
                    return
                }
                
                // Set pdf attachment to persistent attachment
                await MainActor.run {
                    pdfAttachment = persistentAttachment
                }
            }
        }
        .onChange(of: voiceDocumentsFilepath) { newValue in
            // Ensure unwrap newValue, otherwise return TODO: Make sure all errors with setting newValue are handled before this, since this should not do anything if newValue is set to false
            guard let newValue = newValue else {
                return
            }
            
            Task {
                // Defer setting isLoading to false
                defer {
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
                
                // Set isLoading to true
                DispatchQueue.main.async {
                    isLoading = true
                }
                
                // Create persistent attachment
                let persistentAttachment: PersistentAttachment
                do {
                    persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
                        type: .voice,
                        documentsFilePath: newValue,
                        in: viewContext)
                } catch {
                    // TODO: Handle Errors if Necessary
                    print("Error creating PersistentAttachment in AttachmentsView... \(error)")
                    alertShowingErrorAttaching = true
                    return
                }
                
                // Set voice attachment to persistent attachment
                await MainActor.run {
                    voiceAttachment = persistentAttachment
                }
            }
        }
        .onChange(of: attachedWebUrl) { newValue in
            // Ensure unwrap newValue, otherwise return TODO: Make sure all errors with setting newValue are handled before this, since this should not do anything if newValue is set to false
            guard let newValue = newValue else {
                return
            }
            
            Task {
                // Defer setting isLoading to false
                defer {
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
                
                // Set isLoading to true
                DispatchQueue.main.async {
                    isLoading = true
                }
                
                // Create persistent attachment
                let persistentAttachment: PersistentAttachment
                do {
                    persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createWebsiteAttachmentUpdateCachedTextAndGeneratedTitle(
                        externalURL: newValue,
                        in: viewContext)
                } catch {
                    // TODO: Handle Errors if Necessary
                    print("Error creating PersistentAttachment in AttachmentsView... \(error)")
                    alertShowingErrorAttaching = true
                    return
                }
                
                // Set webpage attachment to persistent attachment
                await MainActor.run {
                    webpageAttachment = persistentAttachment
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
}

//#Preview {
//    
//    AttachmentsContainer(
//        displayStyle: .vertical,
//        imageAttachment: .constant(nil),
//        pdfAttachment: .constant(nil),
//        voiceAttachment: .constant(nil),
//        webpageAttachment: .constant(nil))
//    
//}
