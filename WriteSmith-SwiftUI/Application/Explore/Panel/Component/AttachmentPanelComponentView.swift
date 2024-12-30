//
//  AttachmentPanelComponentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/20/24.
//

import SwiftUI

struct AttachmentPanelComponentView: PanelComponentViewProtocol {
    
    @Binding var component: PanelComponent
    @State var attachmentComponentContent: AttachmentPanelComponentContent
    
    
    @State private var isDisplayingAttachmentTypeSelector = false
    
    @State private var pdfAttachment: PersistentAttachment?
    @State private var voiceAttachment: PersistentAttachment?
    @State private var webpageAttachment: PersistentAttachment?
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            // Title
            TitlePanelComponentView(
                text: component.titleText,
                required: component.requiredUnwrapped)
            
            // Attachments
            ScrollView(.horizontal) {
                LazyHStack {
                    // Add Attachment Button
                    Button(action: {
                        isDisplayingAttachmentTypeSelector = true
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundStyle(Colors.buttonBackground)
                            .frame(width: 120, height: 160)
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    }
                    
                    // Attachments
                    ForEach(component.persistentAttachments) { persistentAttachment in
                        AttachmentMiniView(
                            attachment: persistentAttachment,
                            showsDeleteButton: true)
                            .foregroundStyle(Colors.buttonBackground)
                            .padding(8)
                            .frame(width: 120, height: 160)
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    }
                }
            }
        }
        .sheet(isPresented: $isDisplayingAttachmentTypeSelector) {
            VStack {
                // Title
                HStack {
                    Text("Attach")
                        .font(.custom(Constants.FontName.heavy, size: 24.0))
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                // Subtitle
                HStack {
                    Text("AI will see the file you select.")
                        .font(.custom(Constants.FontName.body, size: 14.0))
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                // Attachments View
                AttachmentsContainer(
                    allowedAttachmentTypes: [.pdfOrText, .voice, .webUrl],
                    displayStyle: .vertical,
                    imageAttachment: .constant(nil),
                    pdfAttachment: $pdfAttachment,
                    voiceAttachment: $voiceAttachment,
                    webpageAttachment: $webpageAttachment)
                
                Spacer()
                
                // Close Button
                Button(action: {
                    isDisplayingAttachmentTypeSelector = false
                }) {
                    HStack {
                        Spacer()
                        
                        Text("Close")
                            .font(.custom(Constants.FontName.body, size: 20.0))
                            .foregroundStyle(Colors.buttonBackground)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Colors.elementTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
            .padding()
            .background(Colors.background)
            .presentationDetents([.medium])
            .onChange(of: pdfAttachment) { newValue in
                // If newValue can be unwrapped append to component persistentAttachments
                if let newValue = newValue {
                    component.persistentAttachments.append(newValue)
                    
                    // Update finalizedPrompt
                    if let cachedText = newValue.cachedText {
                        updateFinalizedPrompt(cachedText)
                    }
                }
                
                // Dismiss
                isDisplayingAttachmentTypeSelector = false
            }
            .onChange(of: voiceAttachment) { newValue in
                // If newValue can be unwrapped append to component persistentAttachments
                if let newValue = newValue {
                    component.persistentAttachments.append(newValue)
                    
                    // Update finalizedPrompt
                    if let cachedText = newValue.cachedText {
                        updateFinalizedPrompt(cachedText)
                    }
                }
                
                // Dismiss
                isDisplayingAttachmentTypeSelector = false
            }
            .onChange(of: webpageAttachment) { newValue in
                // If newValue can be unwrapped append to component persistentAttachments
                if let newValue = newValue {
                    component.persistentAttachments.append(newValue)
                    
                    // Update finalizedPrompt
                    if let cachedText = newValue.cachedText {
                        updateFinalizedPrompt(cachedText)
                    }
                }
                
                // Dismiss
                isDisplayingAttachmentTypeSelector = false
            }
        }
    }
    
    func updateFinalizedPrompt(_ finalizedPrompt: String) {
        component.finalizedPrompt = finalizedPrompt
    }
    
}

//#Preview {
//    
//    let attachmentComponentContent = AttachmentPanelComponentContent()
//    
//    return AttachmentPanelComponentView(
//        component: .constant(PanelComponent(
//            componentID: "1",
//            content: .attachment(attachmentComponentContent),
//            titleText: "Title text",
//            detailTitle: "Detail title",
//            detailText: "This is the detail text",
//            promptPrefix: nil,
//            required: true)),
//        attachmentComponentContent: attachmentComponentContent
//    )
//    .background(Colors.background)
//    
//}
