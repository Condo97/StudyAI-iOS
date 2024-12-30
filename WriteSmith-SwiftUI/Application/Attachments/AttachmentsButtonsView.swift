//
//  AttachmentsButtonsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/17/24.
//

import SwiftUI

struct AttachmentsButtonsView: View {
    
    var allowedAttachmentTypes: [AttachmentType]
    @Binding var imageDocumentsFilepath: String?
    @Binding var pdfDocumentsFilepath: String?
    @Binding var voiceDocumentsFilepath: String?
    @Binding var attachedWebUrl: URL?
    var imageAttachmentSubtitle: LocalizedStringKey
    var pdfAttachmentSubtitle: LocalizedStringKey
    var voiceAttachmentSubtitle: LocalizedStringKey
    var webAttachmentSubtitle: LocalizedStringKey
    var cornerRadius: CGFloat = 20.0
    var itemMaxWidth: CGFloat = .infinity
    var itemMaxHeight: CGFloat = .infinity
    
    var body: some View {
        ForEach(allowedAttachmentTypes, id: \.self) { attachmentType in
//            if allowedAttachmentTypes.contains(.image) {
            if attachmentType == .image {
                AttachImageButton(
                    imageDocumentsFilepath: $imageDocumentsFilepath,
                    subtitle: imageAttachmentSubtitle)
                    .padding(8)
                    .frame(maxWidth: itemMaxWidth, maxHeight: itemMaxHeight)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            
//            if allowedAttachmentTypes.contains(.pdfOrText) {
            if attachmentType == .pdfOrText {
                AttachPDFButton(
                    pdfDocumentsFilepath: $pdfDocumentsFilepath,
                    subtitle: pdfAttachmentSubtitle)
                    .padding(8)
                    .frame(maxWidth: itemMaxWidth, maxHeight: itemMaxHeight)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            
//            if allowedAttachmentTypes.contains(.voice) {
            if attachmentType == .voice {
                AttachVoiceButton(
                    voiceDocumentsFilepath: $voiceDocumentsFilepath,
                    subtitle: voiceAttachmentSubtitle)
                    .padding(8)
                    .frame(maxWidth: itemMaxWidth, maxHeight: itemMaxHeight)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            
//            if allowedAttachmentTypes.contains(.webUrl) {
            if attachmentType == .webUrl {
                AttachURLButton(
                    url: $attachedWebUrl,
                    subtitle: webAttachmentSubtitle)
                    .padding(8)
                    .frame(maxWidth: itemMaxWidth, maxHeight: itemMaxHeight)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
        }
    }
    
}

//#Preview {
//    
//    AttachmentsButtonsView(
//        allowedAttachmentTypes: [.image, .pdfOrText, .voice, .webUrl],
//        imageDocumentsFilepath: .constant(nil),
//        pdfDocumentsFilepath: .constant(nil),
//        voiceDocumentsFilepath: .constant(nil),
//        attachedWebUrl: .constant(nil),
//        imageAttachmentSubtitle: "Snap or upload an image to talk about it with AI.",
//        pdfAttachmentSubtitle: "Add a PDF or text doc. Send an assignment to ask questions.",
//        voiceAttachmentSubtitle: "Record or upload a lecture, speech, call, any voice recording.",
//        webAttachmentSubtitle: "Chat about an online source, lecture, assignment, more.")
//    
//}
