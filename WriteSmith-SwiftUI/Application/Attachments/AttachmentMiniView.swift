//
//  AttachmentMiniView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import SwiftUI

struct AttachmentMiniView: View {
    
    @State var attachment: PersistentAttachment
    @State var showsDeleteButton: Bool
    
    
    enum DeleteButtonStates {
        case notPressed
        case pressedOnce
    }
    
    @Namespace private var namespace
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var deleteButtonState: DeleteButtonStates = .notPressed
    
    @State private var deleteButtonMatchedGeometryEffectID: String = "deleteButton"
    
    private let faceFrameDiameter: CGFloat = 76.0
    
    
    var body: some View {
        ZStack {
            VStack {
                // Image
                if let attachmentTypeString = attachment.attachmentType,
                   let attachmentType = AttachmentType(rawValue:  attachmentTypeString) {
                    switch attachmentType {
                    case .flashcards:
                        Image(systemName: "rectangle.on.rectangle.angled")
                            .imageScale(.large)
                            .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                            .padding()
                            .background(Colors.background)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    case .image:
                        if let attachmentFilePath = attachment.documentsFilePath,
                           let uiImage = try? DocumentSaver.getImage(from: attachmentFilePath) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(height: faceFrameDiameter)
                        } else {
                            // TODO: Show Default Image
                        }
                    case .pdfOrText:
                        Image(systemName: "doc.text")
                            .imageScale(.large)
                            .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                            .padding()
                            .background(Colors.background)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    case .voice:
                        Image(systemName: "waveform")
                            .imageScale(.large)
                            .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                            .padding()
                            .background(Colors.background)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    case .webUrl:
                        Image(systemName: "link")
                            .imageScale(.large)
                            .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                            .padding()
                            .background(Colors.background)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    }
                } else {
                    // TODO: Show fallback image
                }
                
                var attachmentTypeName: String? {
                    if let attachmentTypeString = attachment.attachmentType,
                       let attachmentType = AttachmentType(rawValue: attachmentTypeString) {
                        
                        return switch attachmentType {
                        case .flashcards: "Flashcards"
                        case .image: "Image"
                        case .pdfOrText: "PDF File"
                        case .voice: "Voice"
                        case .webUrl: "Webpage"
                        }
                    }
                    
                    return nil
                }
                
                // Title
                Text(attachment.generatedTitle ?? attachmentTypeName ?? "Attachment")
                    .font(.custom(Constants.FontName.body, size: 14.0))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                // Filename or URL
                if let attachmentFilenameOrURL = attachment.documentsFilePath ?? attachment.externalURL?.absoluteString {
                    Text(attachmentFilenameOrURL)
                        .font(.custom(Constants.FontName.black, size: 10.0))
                        .lineLimit(1)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        switch deleteButtonState {
                        case .notPressed:
                            // Show "Delete" to confirm deletion
                            deleteButtonState = .pressedOnce
                            
                            // Set to notPressed after a few seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                self.deleteButtonState = .notPressed
                            }
                        case .pressedOnce:
                            // Delete attachment and reset button state
                            Task {
                                do {
                                    try await PersistentAttachmentCDHelper.delete(attachment, in: viewContext)
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error deleting attachment in AttachmentMiniView, continuing... \(error)")
                                }
                                
                                await MainActor.run {
                                    deleteButtonState = .notPressed
                                }
                            }
                        }
                    }) {
                        Text(deleteButtonState == .notPressed ? "\(Image(systemName: "xmark"))" : "Delete")
                            .font(.custom(deleteButtonState == .notPressed ? Constants.FontName.body : Constants.FontName.black, size: 12.0))
                            .foregroundStyle(deleteButtonState == .notPressed ? Colors.elementBackgroundColor : Colors.foreground)
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                            .background(
                                ZStack {
                                    if deleteButtonState == .notPressed {
                                        Circle()
                                            .fill(Colors.background)
                                            .matchedGeometryEffect(id: deleteButtonMatchedGeometryEffectID, in: namespace)
                                    } else {
                                        RoundedRectangle(cornerRadius: 28.0)
                                            .fill(Color(UIColor.systemRed))
                                            .matchedGeometryEffect(id: deleteButtonMatchedGeometryEffectID, in: namespace)
                                    }
                                })
                            .padding(4)
                    }
                }
                
                Spacer()
            }
        }
    }
    
}

//#Preview {
//    
//    let attachment = try! CDClient.mainManagedObjectContext.performAndWait {
//        let attachment = PersistentAttachment(context: CDClient.mainManagedObjectContext)
//        attachment.attachmentType = AttachmentType.webUrl.rawValue
//        attachment.generatedTitle = "Apple Website"
//        attachment.externalURL = URL(string: "https://apple.com/")
//        
//        try CDClient.mainManagedObjectContext.save()
//        
//        return attachment
//    }
//    
//    return ZStack {
//        AttachmentMiniView(
//            attachment: attachment,
//            showsDeleteButton: true)
//        .frame(width: 160, height: 180)
//        .background(Colors.foreground)
//        .clipShape(RoundedRectangle(cornerRadius: 14.0))
//    }
//    .padding()
//    .background(Colors.background)
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
