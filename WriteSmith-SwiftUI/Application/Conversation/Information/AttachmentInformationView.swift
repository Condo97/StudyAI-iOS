//
//  AttachmentInformationView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/15/24.
//

import CoreData
import Foundation
import QuickLook
import SwiftUI

struct AttachmentInformationView: View {
    
    @Binding var isPresented: Bool
    var conversation: Conversation
    @FetchRequest var persistentAttachments: FetchedResults<PersistentAttachment>
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)],
//        predicate: NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation))
    
    private static let attachmentDisplayHeight: CGFloat = 128.0
    
    @State private var quickLookURL: URL?
    
    @State private var fullScreenImageViewImage: Image?
    private var isShowingFullScreenImageViewImage: Binding<Bool> {
        Binding(
            get: {
                fullScreenImageViewImage != nil
            },
            set: { value in
                if !value {
                    fullScreenImageViewImage = nil
                }
            })
    }
    
    @State private var websitePreviewURL: URL?
    private var isDisplayingWebsitePreview: Binding<Bool> {
        Binding(
            get: {
                websitePreviewURL != nil
            },
            set: { value in
                if !value {
                    websitePreviewURL = nil
                }
            })
    }
    
    @State private var flashCardCollection: FlashCardCollection?
    private var isShowingFlashCardCollectionEditor: Binding<Bool> {
        Binding(
            get: {
                flashCardCollection != nil
            },
            set: { value in
                if !value {
                    flashCardCollection = nil
                }
            })
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16.0) {
                // Attachment Display
                attachmentDisplay
                
                // Attachment Title
                if let title = persistentAttachments.first?.generatedTitle {
                    // TODO: Maybe this should be an indicator that flash cards should be their own thing, since they don't have a generated title, or that maybe they should still be a persistent attachment but just not generate the title but also maybe double check and make sure it is not using the generated title even if it gets generated and uses the user specified one instead or maybe make the edit thing just edit the persistent attachment title rather than the flash card collection title but there are better ways to do it
                    Text(title)
                        .font(.custom(Constants.FontName.black, size: 28.0))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Colors.textOnBackgroundColor)
                }
                
                previewButton
                
                // Information View
                InformationView(
                    isPresented: $isPresented,
                    conversation: conversation)
                
                Spacer()
            }
            .padding([.top, .leading, .trailing]) // This is here to show the scroll indicators outside the padding
        }
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.isPresented = false
                    }) {
                        Text(Image(systemName: "chevron.down"))
                            .font(.custom(Constants.FontName.body, size: 24.0))
                    }
                    .padding(.trailing)
                    .foregroundStyle(Colors.buttonBackground)
                }
                
                Spacer()
            }
            .padding()
        }
        .quickLookPreview($quickLookURL)
        .fullScreenCover(isPresented: isShowingFullScreenImageViewImage) {
            FullScreenImageView(
                isPresented: isShowingFullScreenImageViewImage,
                image: $fullScreenImageViewImage)
        }
        .fullScreenCover(isPresented: isShowingFlashCardCollectionEditor) {
            if let flashCardCollection = flashCardCollection {
                FlashCardCollectionEditorContainer(
                    isPresented: isShowingFlashCardCollectionEditor,
                    initialTitle: persistentAttachments.first?.generatedTitle ?? "",
                    flashCardCollection: flashCardCollection)
            }
        }
        .popover(isPresented: isDisplayingWebsitePreview) {
            ZStack {
                WebView(url: $websitePreviewURL)
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isDisplayingWebsitePreview.wrappedValue = false
                        }) {
                            Text(Image(systemName: "chevron.down"))
                                .font(.custom(Constants.FontName.body, size: 24.0))
                                .foregroundStyle(Colors.elementTextColor)
                                .padding()
                                .background(Colors.elementBackgroundColor)
                                .clipShape(Circle())
                                .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    var attachmentDisplay: some View {
        Button(action: displayAttachmentDetail) {
            ZStack {
                if let persistentAttachment = persistentAttachments.first,
                   let attachmentTypeString = persistentAttachment.attachmentType,
                   let attachmentType = AttachmentType(rawValue: attachmentTypeString) {
                    switch attachmentType {
                    case .flashcards:
                        VStack {
                            Text(Image(systemName: "rectangle.on.rectangle.angled"))
                                .font(.custom(Constants.FontName.light, size: 68.0))
                            
                            Text("Flash Cards")
                                .font(.custom(Constants.FontName.black, size: 12.0))
                        }
                        .padding()
                    case .image:
                        if let documentsFilePath = persistentAttachment.documentsFilePath,
                           let uiImage = try? DocumentSaver.getImage(from: documentsFilePath) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(height: AttachmentInformationView.attachmentDisplayHeight)
                        } else {
                            // TODO: Show blank image or something
                        }
                    case .pdfOrText:
                        VStack {
                            Text(Image(systemName: "doc.text"))
                                .font(.custom(Constants.FontName.light, size: 68.0))
                            
                            Text("PDF or File")
                                .font(.custom(Constants.FontName.black, size: 12.0))
                        }
                        .padding()
                    case .voice:
                        VStack {
                            Image(systemName: "waveform")
                                .font(.custom(Constants.FontName.light, size: 68.0))
                            
                            Text("Voice")
                                .font(.custom(Constants.FontName.black, size: 12.0))
                        }
                        .padding()
                    case .webUrl:
                        VStack {
                            Image(systemName: "link")
                                .font(.custom(Constants.FontName.light, size: 68.0))
                            
                            Text("Web Link")
                                .font(.custom(Constants.FontName.black, size: 12.0))
                        }
                        .padding()
                    }
                } else {
                    // TODO: Show blank image or something
                }
            }
        }
        .foregroundStyle(Colors.elementBackgroundColor)
        .frame(width: AttachmentInformationView.attachmentDisplayHeight, height: AttachmentInformationView.attachmentDisplayHeight)
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
    var previewButton: some View {
        VStack {
            if let persistentAttachment = persistentAttachments.first,
               let attachmentTypeString = persistentAttachment.attachmentType,
               let attachmentType = AttachmentType(rawValue: attachmentTypeString) {
                Button(action: displayAttachmentDetail
//                    // If documentsFilePath can be unwrapped and attachmentType is image and uiImage can be unwrapped set fullScreenImagePreviewImage to image, otherwise set quickLookURL to documentsFilePath fullURL from DocumentSaver which is the documentsFilePath appended to the documents folder path since it is a image pdf or voice, otherwise if externalURL can be unwrapped set websitePreviewURL to externalURL since it is a website
//                    if let documentsFilePath = persistentAttachment.documentsFilePath {
//                        if attachmentType == .image, let uiImage = try? DocumentSaver.getImage(from: documentsFilePath) { // TODO: Should I remove the try? here?
//                            // If attachmentType is image and image can be unwrapped from DocumentSaver getImage get image and set to fullScreenImagePreviewImage
//                            fullScreenImageViewImage = Image(uiImage: uiImage)
//                        } else {
//                            // Otherwise set quickLookURL to DocumentSaver full URL from documentsFilePath
//                            quickLookURL = DocumentSaver.getFullURL(from: documentsFilePath)
//                        }
//                    } else if let externalURL = persistentAttachment.externalURL {
//                        // If externalURL can be unwrapped set quickLookURL to it
//                        websitePreviewURL = externalURL
//                    }
                ) {
                    HStack {
                        // Icon Image
                        let iconImageSystemName: String = {
                            switch attachmentType { // TODO: This and attachmentTypeTitle should be in an extension of attachmentType
                            case .flashcards: "rectangle.on.rectangle.angled"
                            case .image: "image"
                            case .pdfOrText: "doc.text"
                            case .voice: "waveform"
                            case .webUrl: "link"
                            }
                        }()
                        Image(systemName: iconImageSystemName)
                        
                        // Text
                        VStack(alignment: .leading) {
                            // Title
                            let viewAttachmentTitle: String = {
                                switch attachmentType { // TODO: This and iconImageSystemName should be in an extension of attachmentType
                                case .flashcards: "Edit Flash Cards"
                                case .image: "Preview Image"
                                case .pdfOrText: "Preview Document"
                                case .voice: "Preview Voice"
                                case .webUrl: "Preview Webpage"
                                }
                            }()
                            Text(viewAttachmentTitle)
                            
                            // Document Name
                            let documentName: String = {
                                // If documentsFilePath can be unwrapped return it as documentName since that will be the name of the document for image pdf and voice, if externalURL can be unwrapped return it as documentName since it will be the name of the document for a website
                                if let documentsFilePath = persistentAttachment.documentsFilePath {
                                    return documentsFilePath
                                } else if let externalURL = persistentAttachment.externalURL {
                                    return externalURL.absoluteString
                                }
                                
                                // Otherwise return "Tap to View Document"
                                return "Tap to View Document"
                            }()
                            Text(documentName)
                                .font(.custom(Constants.FontName.blackOblique, size: 10.0))
                                .opacity(0.4)
                        }
                        
                        Spacer()
                        
                        // Detail Disclosure Image
                        Image(systemName: "chevron.right")
                    }
                }
            } else {
                // TODO: Show something here
            }
        }
        .font(.custom(Constants.FontName.body, size: 17.0))
        .padding()
        .foregroundStyle(Colors.text)
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
    func displayAttachmentDetail() {
        if let persistentAttachment = persistentAttachments.first,
           let attachmentTypeString = persistentAttachment.attachmentType,
           let attachmentType = AttachmentType(rawValue: attachmentTypeString) {
            if let documentsFilePath = persistentAttachment.documentsFilePath {
                if attachmentType == .image, let uiImage = try? DocumentSaver.getImage(from: documentsFilePath) { // TODO: Should I remove the try? here?
                    // If attachmentType is image and image can be unwrapped from DocumentSaver getImage get image and set to fullScreenImagePreviewImage
                    fullScreenImageViewImage = Image(uiImage: uiImage)
                } else {
                    // Otherwise set quickLookURL to DocumentSaver full URL from documentsFilePath
                    quickLookURL = DocumentSaver.getFullURL(from: documentsFilePath)
                }
            } else if let externalURL = persistentAttachment.externalURL {
                // If externalURL can be unwrapped set quickLookURL to it
                websitePreviewURL = externalURL
            } else if let flashCardCollection = persistentAttachment.flashCardCollection {
                // Set instance flashCardCollection to flashCardCollection
                self.flashCardCollection = flashCardCollection
            }
        }
    }
    
}


//#Preview {
//    
//    let attachment = PersistentAttachment(context: CDClient.mainManagedObjectContext)
//    attachment.attachmentType = AttachmentType.pdfOrText.rawValue
//    attachment.generatedTitle = "Test Title"
//    
//    let conversation = Conversation(context: CDClient.mainManagedObjectContext)
//    conversation.addToPersistentAttachments(attachment)
//    
//    try? CDClient.mainManagedObjectContext.performAndWait {
//        try CDClient.mainManagedObjectContext.save()
//    }
//    
//    return AttachmentInformationView(
//        isPresented: .constant(true),
//        conversation: conversation,
//        persistentAttachments: FetchRequest(
//            sortDescriptors: [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)],
//            predicate: NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation))
//    )
//    .background(Colors.background)
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    .environmentObject(PremiumUpdater())
//    .environmentObject(ProductUpdater())
//    
//}
