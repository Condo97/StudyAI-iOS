//
//  AttachmentsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import CoreData
import PDFKit
import SwiftUI

struct AttachmentsView: View {
    
    enum DisplayStyle {
        case vertical
        case horizontalScroll
        case grid
    }
    
    var allowedAttachmentTypes: [AttachmentType]// = [.image, .pdfOrText, .voice, .webUrl]
    var displayStyle: DisplayStyle
    @Binding var imageDocumentsFilepath: String?
    @Binding var pdfDocumentsFilepath: String?
    @Binding var voiceDocumentsFilepath: String?
    @Binding var attachedWebUrl: URL?
    var imageAttachmentSubtitle: LocalizedStringKey =   "Snap or upload an image to talk about it with AI."
    var pdfAttachmentSubtitle: LocalizedStringKey =     "Add PDF or text doc. Send assignment, ask questions."
    var voiceAttachmentSubtitle: LocalizedStringKey =   "Record or upload a lecture, speech, call, any voice."
    var webAttachmentSubtitle: LocalizedStringKey =     "Chat about any online source, lecture, more."
    
    var body: some View {
        if displayStyle == .vertical {
            VStack {
                AttachmentsButtonsView(
                    allowedAttachmentTypes: allowedAttachmentTypes,
                    imageDocumentsFilepath: $imageDocumentsFilepath,
                    pdfDocumentsFilepath: $pdfDocumentsFilepath,
                    voiceDocumentsFilepath: $voiceDocumentsFilepath,
                    attachedWebUrl: $attachedWebUrl,
                    imageAttachmentSubtitle: imageAttachmentSubtitle,
                    pdfAttachmentSubtitle: pdfAttachmentSubtitle,
                    voiceAttachmentSubtitle: voiceAttachmentSubtitle,
                    webAttachmentSubtitle: webAttachmentSubtitle)
            }
        } else if displayStyle == .horizontalScroll {
            ScrollView(.horizontal) {
                HStack {
                    AttachmentsButtonsView(
                        allowedAttachmentTypes: allowedAttachmentTypes,
                        imageDocumentsFilepath: $imageDocumentsFilepath,
                        pdfDocumentsFilepath: $pdfDocumentsFilepath,
                        voiceDocumentsFilepath: $voiceDocumentsFilepath,
                        attachedWebUrl: $attachedWebUrl,
                        imageAttachmentSubtitle: imageAttachmentSubtitle,
                        pdfAttachmentSubtitle: pdfAttachmentSubtitle,
                        voiceAttachmentSubtitle: voiceAttachmentSubtitle,
                        webAttachmentSubtitle: webAttachmentSubtitle,
                        itemMaxWidth: 150.0)
                    .frame(height: 100.0)
                }
                .padding([.leading, .trailing]) // TODO: iOS 17 and above has safeAreaPadding which takes care of the padding for scroll views for child views and should be used instead of this at some point, this is the reason for all the leading trailing paddings in ConversationView and subviews that are inside of it
            }
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                AttachmentsButtonsView(
                    allowedAttachmentTypes: allowedAttachmentTypes,
                    imageDocumentsFilepath: $imageDocumentsFilepath,
                    pdfDocumentsFilepath: $pdfDocumentsFilepath,
                    voiceDocumentsFilepath: $voiceDocumentsFilepath,
                    attachedWebUrl: $attachedWebUrl,
                    imageAttachmentSubtitle: imageAttachmentSubtitle,
                    pdfAttachmentSubtitle: pdfAttachmentSubtitle,
                    voiceAttachmentSubtitle: voiceAttachmentSubtitle,
                    webAttachmentSubtitle: webAttachmentSubtitle)
            }
        }
    }
    
}

//#Preview {
//    VStack {
//        Spacer()
//        
//        HStack {
//            Spacer()
//            
//            AttachmentsView(
//                allowedAttachmentTypes: [.image, .pdfOrText, .voice, .webUrl],
//                displayStyle: .vertical,
//                imageDocumentsFilepath: .constant(nil),
//                pdfDocumentsFilepath: .constant(nil),
//                voiceDocumentsFilepath: .constant(nil),
//                attachedWebUrl: .constant(nil))
//            .padding()
//            .background(Colors.background)
//            
//            Spacer()
//        }
//        
//        Spacer()
//    }
//}
