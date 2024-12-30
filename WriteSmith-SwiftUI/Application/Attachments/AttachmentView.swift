//
//  AttachmentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/24/24.
//

import SwiftUI

struct AttachmentView: View {
    
    var persistentAttachment: PersistentAttachment
    var diameter: CGFloat = 76.0
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if let attachmentTypeString = persistentAttachment.attachmentType,
           let attachmentType = AttachmentType(rawValue: attachmentTypeString) {
            switch attachmentType {
            case .flashcards:
                Image(systemName: "rectangle.on.rectangle.angled")
                    .imageScale(.medium)
                    .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                    .padding()
            case .image:
                if let attachmentFilePath = persistentAttachment.documentsFilePath,
                   let uiImage = try? DocumentSaver.getImage(from: attachmentFilePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: diameter)
                } else {
                    // TODO: Show Default Image
                }
            case .pdfOrText:
                Image(systemName: "doc.text")
                    .imageScale(.medium)
                    .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                    .padding()
            case .voice:
                Image(systemName: "waveform")
                    .imageScale(.medium)
                    .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                    .padding()
            case .webUrl:
                Image(systemName: "link")
                    .imageScale(.medium)
                    .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                    .padding()
            }
        }
    }
    
}

//#Preview {
//    
//    let filepath = "testtesttest"
//    let image = UIImage(systemName: "chevron.up")
//    try! DocumentSaver.save(image!.jpegData(compressionQuality: 8)!, to: filepath)
//    
//    let persistentAttachment = PersistentAttachment(context: CDClient.mainManagedObjectContext)
//    persistentAttachment.attachmentType = AttachmentType.image.rawValue
//    persistentAttachment.documentsFilePath = filepath
//    
//    return AttachmentView(persistentAttachment: persistentAttachment)
//    
//}
