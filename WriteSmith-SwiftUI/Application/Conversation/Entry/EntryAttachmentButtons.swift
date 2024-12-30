////
////  EntryAttachmentButtons.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 10/6/24.
////
//
//import SwiftUI
//
//struct EntryAttachmentButtons: View {
//    
//    @Binding var cameraViewImageData: ImageData?
//    @Binding var imagesData: [ImageData]
//    @Binding var isDisplayingAttachmentButtons: Bool
//    @Binding var isDisplayingPhotoPicker: Bool
//    var onOpenAttachFile: () -> Void
//    
//    
//    var body: some View {
//        // Attachment Buttons
//        HStack(alignment: .bottom, spacing: 12.0) {
//            if isDisplayingAttachmentButtons {
//                // Camera
//                KeyboardDismissingButton(action: {
//                    cameraViewImageData = ImageData()
//                }) {
//                    Image(systemName: "camera")
//                        .fontWeight(.bold)
//                }
//                .transition(.push(from: .leading).combined(with: .scale))
//                
//                // Photo
//                KeyboardDismissingButton(action: {
//                    // Photo picker
//                    isDisplayingPhotoPicker = true
//                }) {
//                    Image(systemName: "photo")
//                        .fontWeight(.bold)
//                }
//                .transition(.push(from: .leading).combined(with: .scale))
//                
//                // File
//                KeyboardDismissingButton(action: {
//                    // Open file attach popup
//                    onOpenAttachFile()
//                }) {
//                    Image(systemName: "folder")
//                        .fontWeight(.bold)
//                }
//                .transition(.push(from: .leading).combined(with: .scale))
//            } else {
//                Button(action: {
//                    withAnimation(.bouncy) {
//                        isDisplayingAttachmentButtons.toggle()
//                    }
//                }) {
//                    Image(systemName: "plus.circle.fill")
//                        .foregroundStyle(Colors.userChatBubbleColor, Colors.background)
//                        .fontWeight(.bold)
//                }
//                .transition(.push(from: .leading).combined(with: .scale))
//            }
//        }
//        .foregroundStyle(Colors.text)
//        .frame(maxHeight: .infinity, alignment: .bottom)
//        .padding(.vertical, 12)
//    }
//    
//}
//
////#Preview {
////    EntryAttachmentButtons()
////}
