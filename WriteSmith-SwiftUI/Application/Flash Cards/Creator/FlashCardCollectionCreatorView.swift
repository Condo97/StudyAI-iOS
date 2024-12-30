//
//  FlashcardCollectionCreatorView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import SwiftUI

struct FlashCardCollectionCreatorView: View {
    
    @Binding var imageDocumentsFilepath: String?
    @Binding var pdfDocumentsFilepath: String?
    @Binding var voiceDocumentsFilepath: String?
    @Binding var attachedWebURL: URL?
    var onClose: () -> Void
    var onSubmitPromptEntry: (_ prompt: String) -> Void
    var onOpenManualEntry: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isDisplayingUploadTips: Bool = false
    
    @State private var isShowingPromptEntry: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // TODO: Document scanner that allows for multiple images to be scanned and uploaded
                
                // TODO: Media files, though that is handled by voice it should have a more obvious presentation
                
                // TODO: Paste text
                
                // Title
                HStack {
                    Text("Create Flash Card Set")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                    
                    Spacer()
                }
                
                // Attachments Entry TODO: Basically when one is submitted it needs to start the flashcard generation and then generate the flashcards then associate them with a PersistentAttachment and then Conversation
                AttachmentsView(
                    allowedAttachmentTypes: [.image, .pdfOrText, .voice, .webUrl],
                    displayStyle: .grid,
                    imageDocumentsFilepath: $imageDocumentsFilepath,
                    pdfDocumentsFilepath: $pdfDocumentsFilepath,
                    voiceDocumentsFilepath: $voiceDocumentsFilepath,
                    attachedWebUrl: $attachedWebURL,
                    imageAttachmentSubtitle: "Scan or upload an image to create flash cards.",
                    pdfAttachmentSubtitle: "Add a PDF or text doc as a source for flash cards.",
                    voiceAttachmentSubtitle: "Use or record a lecture, speech, call, or more.",
                    webAttachmentSubtitle: "Create flash cards from a webpage.")
                
                // Prompt Entry
                Button(action: {
                    isShowingPromptEntry = true
                }) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(Image(systemName: "pencil.line"))")
                                .font(.custom(Constants.FontName.body, size: 17.0))
                                .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                .padding(4)
                                .frame(width: 38.0, height: 38.0)
                                .background(Colors.background)
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                            
                            Text("Prompt")
                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                                .foregroundStyle(Colors.text)
                            
                            Spacer()
                        }
                        
                        Text("Auto generate flash cards from a prompt you write.")
                            .font(.custom(Constants.FontName.body, size: 10.0))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Colors.text)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                }
                
                // Manual Entry
                Button(action: {
                    onOpenManualEntry()
                }) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(Image(systemName: "keyboard"))")
                                .font(.custom(Constants.FontName.body, size: 17.0))
                                .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                .padding(4)
                                .frame(width: 38.0, height: 38.0)
                                .background(Colors.background)
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                            
                            Text("Manual")
                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                                .foregroundStyle(Colors.text)
                            
                            Spacer()
                        }
                        
                        Text("Enter terms and definitions manually.")
                            .font(.custom(Constants.FontName.body, size: 10.0))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Colors.text)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                }
                
                // "You can add and edit cards later." Text maybe here TODO: The first chat that should be sent should let the user know that they can revise the flashcards directly in the chat
                
                // Tips for Creating
                Button("\(Image(systemName: "lightbulb")) Tips for Creating") {
                    isDisplayingUploadTips = true
                }
                .padding()
                
                Spacer()
                
                Text("\(Image(systemName: "lock")) Files, flash cards, and chats are never saved on our sever.")
                    .font(.custom(Constants.FontName.body, size: 10.0))
                    .opacity(0.6)
            }
            .padding()
            .background(Colors.background)
            .navigationTitle("Create Flash Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Colors.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", action: onClose)
                }
            }
            .sheet(isPresented: $isDisplayingUploadTips) {
                VStack {
                    Capsule()
                        .frame(width: 40.0, height: 4.0)
                        .opacity(0.6)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 16.0) {
                            Text("Try uploading")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                            
                            HStack {
                                Image(systemName: "doc.text")
                                    .imageScale(.small)
                                    .foregroundStyle(Colors.elementBackgroundColor)
                                    .padding(8)
                                    .background(Circle().fill(Colors.elementBackgroundColor).opacity(0.2))
                                
                                Text("Class notes")
                            }
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            
                            HStack {
                                Image(systemName: "rectangle.stack")
                                    .imageScale(.small)
                                    .foregroundStyle(Colors.elementBackgroundColor)
                                    .padding(8)
                                    .background(Circle().fill(Colors.elementBackgroundColor).opacity(0.2))
                                
                                Text("Lecture slides")
                            }
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            
                            HStack {
                                Image(systemName: "book.closed")
                                    .imageScale(.small)
                                    .foregroundStyle(Colors.elementBackgroundColor)
                                    .padding(8)
                                    .background(Circle().fill(Colors.elementBackgroundColor).opacity(0.2))
                                
                                Text("Readings")
                            }
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            
                            Text("Tips for uploading")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                            
                            Text("• Files can be any type")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                            Text("• Upload between 100 and 50000 characters!")
                                .font(.custom(Constants.FontName.body, size: 14.0))
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Colors.background)
                .presentationDetents([.medium])
            }
            .clearFullScreenCover(isPresented: $isShowingPromptEntry) {
                FlashCardCollectionCreatorPromptEntryView(
                    isPresented: $isShowingPromptEntry,
                    onSubmit: onSubmitPromptEntry)
                .padding()
                .background(Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding()
            }
        }
    }
    
}

//#Preview {
//    
//    FlashcardCollectionCreatorView()
//    
//}
