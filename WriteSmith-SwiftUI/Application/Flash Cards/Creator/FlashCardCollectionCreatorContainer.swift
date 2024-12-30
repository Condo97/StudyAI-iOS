//
//  FlashCardCollectionCreatorContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/12/24.
//

import SwiftUI

struct FlashCardCollectionCreatorContainer: View {
    
    var onClose: () -> Void
    var onOpenManualEntry: () -> Void
    var onSubmit: (_ textAttachment: String?, _ imageDataAttachment: String?) -> Void
    
    @State private var imageDocumentsFilepath: String?
    @State private var pdfDocumentsFilepath: String?
    @State private var voiceDocumentsFilepath: String?
    @State private var attachedWebUrl: URL?
    
    var body: some View {
        FlashCardCollectionCreatorView(
            imageDocumentsFilepath: $imageDocumentsFilepath,
            pdfDocumentsFilepath: $pdfDocumentsFilepath,
            voiceDocumentsFilepath: $voiceDocumentsFilepath,
            attachedWebURL: $attachedWebUrl,
            onClose: onClose,
            onSubmitPromptEntry: { onSubmit($0, nil) },
            onOpenManualEntry: onOpenManualEntry)
        .onChange(of: imageDocumentsFilepath) { newValue in
            // Ensure unwrap newValue, otherwise show alert and return
            guard let newValue = newValue else {
                // TODO: Handle Errors, show error alert
                print("Could not unwrap imageDocumentsFilepath newValue in FlashCardCollectionCreatorContainer!")
                return
            }
            
            // Ensure get imageData from imageDocumentsFilepath, otherwise show alert and return
            let imageData: Data
            do {
                guard let unwrappedImageData = try DocumentSaver.getImage(from: newValue)?.jpegData(compressionQuality: 0.8) else {
                    // TODO: Handle Errors, show error alert
                    print("Could not unwrap imageData from DocumentSaver in FlashCardCollectionCreatorContainer!")
                    return
                }
                imageData = unwrappedImageData
            } catch {
                // TODO: Handle Errors, show error alert
                print("Error getting image from DocumentSaver in FlashCardCollectionCreatorContainer... \(error)")
                return
            }
            
            // Call onSubmit with encoded imageData
            onSubmit(nil, imageData.base64EncodedString())
        }
        .onChange(of: pdfDocumentsFilepath) { newValue in
            // Ensure unwrap newValue, otherwise show alert and return
            guard let newValue = newValue else {
                // TODO: Handle Errors, show error alert
                print("Could not unwrap pdfDocumentsFilepath newValue in FlashCardCollectionCreatorContainer!")
                return
            }
            
            // Ensure get cachedText from pdf attachment from pdfDocumentsFilepath
            let cachedText: String
            do {
                guard let unwrappedCachedText = try AttachmentAdapter.getPDFCachedText(from: newValue) else {
                    // TODO: Handle Errors, show error alert
                    print("Could not unwrap cachedText from AttachmentAdapter in FlashCardCollectionCreatorContainer!")
                    return
                }
                cachedText = unwrappedCachedText
            } catch {
                // TODO: Handle Errors, show error alert
                print("Error getting cachedText from DocumentSaver in FlashCardCollectionCreatorContainer... \(error)")
                return
            }
            
            // Call onSubmit with cachedText
            onSubmit(cachedText, nil)
        }
        .onChange(of: voiceDocumentsFilepath) { newValue in
            // Ensure unwrap newValue, otherwise show alert and return
            guard let newValue = newValue else {
                // TODO: Handle Errors, show error alert
                print("Could not unwrap pdfDocumentsFilepath newValue in FlashCardCollectionCreatorContainer!")
                return
            }
            
            // Ensure get cachedText from voice attachment from pdfDocumentsFilepath
            Task {
                let cachedText: String
                do {
                    guard let unwrappedCachedText = try await AttachmentAdapter.getVoiceCachedText(from: newValue) else {
                        // TODO: Handle Errors, show error alert
                        print("Could not unwrap cachedText from AttachmentAdapter in FlashCardCollectionCreatorContainer!")
                        return
                    }
                    cachedText = unwrappedCachedText
                } catch {
                    // TODO: Handle Errors, show error alert
                    print("Error getting cachedText from DocumentSaver in FlashCardCollectionCreatorContainer... \(error)")
                    return
                }
                
                // Call onSubmit with cachedText
                onSubmit(cachedText, nil)
            }
        }
        .onChange(of: attachedWebUrl) { newValue in
            // Ensure unwrap newValue, otherwise show alert and return
            guard let newValue = newValue else {
                // TODO: Handle Errors, show error alert
                print("Could not unwrap pdfDocumentsFilepath newValue in FlashCardCollectionCreatorContainer!")
                return
            }
            
            // Ensure get cachedText from voice attachment from pdfDocumentsFilepath
            Task {
                let cachedText: String
                do {
                    guard let unwrappedCachedText = try await AttachmentAdapter.getURLCachedText(from: newValue) else {
                        // TODO: Handle Errors, show error alert
                        print("Could not unwrap cachedText from AttachmentAdapter in FlashCardCollectionCreatorContainer!")
                        return
                    }
                    cachedText = unwrappedCachedText
                } catch {
                    // TODO: Handle Errors, show error alert
                    print("Error getting cachedText from DocumentSaver in FlashCardCollectionCreatorContainer... \(error)")
                    return
                }
                
                // Call onSubmit with cachedText
                onSubmit(cachedText, nil)
            }
        }
    }
    
}

//#Preview {
//    
//    FlashCardCollectionCreatorContainer()
//    
//}
