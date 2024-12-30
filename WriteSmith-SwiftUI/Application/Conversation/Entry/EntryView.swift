//
//  EntryView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/22/23.
//

import SwiftUI

struct EntryView: View, KeyboardReadable {
    
    @State var noUserChatsSent: Bool
//    let initialHeight: CGFloat = 40.0
    let maxHeight: CGFloat
    @ObservedObject var conversationChatGenerator: ConversationChatGenerator
    let onOpenAttachFile: () -> Void // TODO: This should be changed to instead allow for insertion of files directly into the chat
    let onOpenCall: () -> Void
    let onSubmit: (_ text: String, _ image: UIImage?, _ imageURL: String?) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
//    @EnvironmentObject private var premiumUpdater: PremiumUpdater // TODO: Use @Environment with an optional
//    @EnvironmentObject private var remainingUpdater: RemainingUpdater // TODO: Use @Environment with an optional
    
    private let cornerRadius = 14.0
    
    @State private var alertShowingUpgradeForFasterChats: Bool = false
    
    @State private var cameraViewCropFrame: CGRect?
    @State private var cameraViewInitialImage: UIImage?
    
    @State private var isDisplayingAttachmentButtons: Bool = true
    @State private var isDisplayingPhotoPicker: Bool = false
    
    @State private var isShowingCameraView: Bool = false
    @State private var isShowingReviewModel: Bool = false
    @State private var isShowingUltraView: Bool = false
    
    @State private var keyboardStatus: KeyboardStatus?
    
    @State private var text: String = ""
    @State private var image: UIImage?
    @State private var imageURL: String?
    
    @State private var uncroppedImage: UIImage?
    @State private var cropFrame: CGRect?
    
    var buttonDisabled: Bool {
        (text.isEmpty && image == nil && (imageURL == nil || imageURL!.isEmpty)) || conversationChatGenerator.isLoading
    }
    
    var body: some View {
        VStack {
            let _ = Self._printChanges()
            // Image and Text Entry
            HStack(alignment: .bottom, spacing: 12.0) {
                // Attachment Buttons
                HStack(alignment: .bottom, spacing: 12.0) {
                    if isDisplayingAttachmentButtons {
                        // Camera
                        KeyboardDismissingButton(action: {
                            isShowingCameraView = true
                        }) {
                            Image(systemName: "camera")
                                .fontWeight(.bold)
                        }
                        .transition(.push(from: .leading).combined(with: .scale))
                        
                        // Photo
                        KeyboardDismissingButton(action: {
                            // Photo picker
                            isDisplayingPhotoPicker = true
                        }) {
                            Image(systemName: "photo")
                                .fontWeight(.bold)
                        }
                        .transition(.push(from: .leading).combined(with: .scale))
                        
                        // File
                        KeyboardDismissingButton(action: {
                            // Open file attach popup TODO: This should be done in EntryView and so it can be in the chat
                            onOpenAttachFile()
                        }) {
                            Image(systemName: "folder")
                                .fontWeight(.bold)
                        }
                        .transition(.push(from: .leading).combined(with: .scale))
                        //                        .transition(.push(from: .leading))
                        //                        .transition(.scale)
                    } else {
                        Button(action: {
                            withAnimation(.bouncy) {
                                isDisplayingAttachmentButtons.toggle()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Colors.userChatBubbleColor, Colors.background)
                                .fontWeight(.bold)
                        }
                        .transition(.push(from: .leading).combined(with: .scale))
                    }
                }
                .foregroundStyle(Colors.text)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.vertical, 12)
                
                // Text entry
                VStack(alignment: .leading) {
                    // Entry Image
                    if let image = image {
                        Button(action: {
                            // Set initial image and crop frame as necessary
                            if let uncroppedImage = uncroppedImage {
                                // If uncroppedImage can be unwrapped, set cameraViewInitialImage to uncroppedImage and cameraViewCropFrame to cropFrame
                                cameraViewInitialImage = uncroppedImage
                                cameraViewCropFrame = cropFrame
                            } else {
                                // If uncroppedImage is nil, then set cameraViewInitialImage to tempImage
                                cameraViewInitialImage = image
                            }
                            
                            // Show camera view
                            isShowingCameraView = true
                        }) {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200.0)
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                
                                HStack(spacing: 0.0) {
                                    Spacer()
                                    
                                    VStack(spacing: 0.0) {
                                        Button(action: {
                                            withAnimation(.spring) {
                                                self.image = nil
                                            }
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.custom(Constants.FontName.medium, size: 14.0))
                                        }
                                        .foregroundStyle(Colors.elementBackgroundColor)
                                        .padding(6)
                                        .background(Circle()
                                            .fill(Colors.elementTextColor))
                                        
                                        Spacer()
                                    }
                                }
                                .padding(4)
                            }
                        }
                        
                        Divider()
                            .background(Colors.elementTextColor)
                    }
                    
                    HStack(alignment: .bottom) {
                        // Entry Text Field
                        TextField("", text: $text, axis: .vertical)
                            .textFieldTickerTint(Colors.elementTextColor)
                            .placeholder(when: text.isEmpty, placeholder: {
                                Text("Message")
                                    .font(.custom(Constants.FontName.medium, size: 17.0))
                                    .opacity(0.6)
                            })
                            .dismissOnReturn()
                            .font(.custom(Constants.FontName.body, size: 17.0))
                            .padding(.leading, 8)
                        
                        // Entry Submit Button TODO: Replace with speech to text button when empty
                        KeyboardDismissingButton(action: {
                            // Call onSubmit
                            onSubmit(text, image, imageURL)
                            
                            // Set text, image, and imageURL to empty or nil
                            text = ""
                            image = nil
                            imageURL = nil
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24.0)
                                .foregroundStyle(colorScheme == .dark ? Colors.elementTextColor : Colors.userChatBubbleColor)
//                                .foregroundStyle(buttonDisabled ? Colors.text : Colors.userChatBubbleColor)
                        }
                        .disabled(buttonDisabled)
                        .opacity(buttonDisabled ? 0.2 : 1.0)
                    }
                }
//                .padding(8)
//                .frame(minHeight: initialHeight - 2 * textVerticalPadding)
                .frame(maxHeight: maxHeight)
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
//                .fixedSize(horizontal: false, vertical: true)
                .background(RoundedRectangle(cornerRadius: 28.0)
                    .stroke(Colors.text.opacity(0.2), lineWidth: 1.0))
//                .background(Colors.elementBackgroundColor)
//                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .onChange(of: buttonDisabled, perform: { value in
                    print("REE")
                })
                
                // Voice Chat
                Button(action: onOpenCall) {
                    Image(systemName: "person.wave.2.fill")
                        .fontWeight(.bold)
                        .foregroundStyle(Colors.userChatBubbleColor)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.vertical, 12)
            }
            .foregroundStyle(Colors.text)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $isShowingCameraView, content: {
            ZStack {
                CaptureCameraViewControllerRepresentable(
                    //                isShowing: $isShowingCameraView,
                    reset: .constant(false), // TODO: Fix reset for capture camera view
                    withCropFrame: $cropFrame,
                    withImage: $cameraViewInitialImage,
                    onAttach: { image, cropFrame, originalImage in
                        // Set image, cropFrame, and uncroppedImage
                        self.image = image
                        self.cropFrame = cropFrame
                        self.uncroppedImage = originalImage
                        
                        // Dismiss camera view
                        isShowingCameraView = false
                    },
                    onScan: { scanText in
                        // Add scanText to text with a space if text is not empty
                        text += text.isEmpty ? scanText : " " + scanText
                        
                        // Dismiss camera view
                        isShowingCameraView = false
                    })
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isShowingCameraView = false
                        }) {
                            Text(Image(systemName: "xmark"))
                                .font(.custom(Constants.FontName.body, size: 20.0))
                                .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                .padding()
                                .background(Colors.foreground)
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                }
            }
//            .ignoresSafeArea()
        })
        .clearFullScreenCover(isPresented: $conversationChatGenerator.isDisplayingPromoSendImagesView, content: {
            PromoSendImagesView(isShowing: $conversationChatGenerator.isDisplayingPromoSendImagesView, pressedScan: {
                // Dismiss
                conversationChatGenerator.isDisplayingPromoSendImagesView = false
                
                // Get tempImage from image TODO: Image URL stuff
                let tempImage = image
                
                // Set image and imageURL to nil
                withAnimation {
                    image = nil
                    imageURL = nil
                }
                
                // Set initial image and crop frame as necessary
                if let uncroppedImage = uncroppedImage {
                    // If uncroppedImage can be unwrapped, set cameraViewInitialImage to uncroppedImage and cameraViewCropFrame to cropFrame
                    cameraViewInitialImage = uncroppedImage
                    cameraViewCropFrame = cropFrame
                } else {
                    // If uncroppedImage is nil, then set cameraViewInitialImage to tempImage
                    cameraViewInitialImage = tempImage
                }
                
                // Show cameraView
                isShowingCameraView = true
            })
        })
        .imagePicker(
            isPresented: $isDisplayingPhotoPicker,
            onSelect: { image in
                // Set image to image
                self.image = image
            })
        .alert("Upgrade for FREE", isPresented: $alertShowingUpgradeForFasterChats, actions: {
            Button("Cancel", role: nil, action: {
                
            })
            
            Button("Start Free Trial", role: .cancel, action: {
                isShowingUltraView = true
            })
        }) {
            Text("Please upgrade to send chats faster. Good news... you can get this and GPT-4o for FREE!")
        }
        .onReceive(keyboardPublisher) { newValue in // TODO: This seems to be the latest code and I'm gonna repeat this but it should be abstracted and moved so that the reference is more straightforeward
            DispatchQueue.main.async {
                self.keyboardStatus = newValue
            }
        }
        .onChange(of: keyboardStatus) { newValue in
            if newValue == .willShow {
                // If keyboard will show hide attachment buttons
                withAnimation {
                    isDisplayingAttachmentButtons = false
                }
            } else if newValue == .willHide {
                // If keyboard will hide show attachment buttons
                withAnimation {
                    isDisplayingAttachmentButtons = true
                }
            }
        }
    }
    
}

//@available(iOS 17.0, *)
//#Preview(traits: .sizeThatFitsLayout) {
//
////    let conversation = Conversation(context: CDClient.mainManagedObjectContext)
////
////    let chat1 = Chat(context: CDClient.mainManagedObjectContext)
////    chat1.text = "Chat text"
////    chat1.conversation = conversation
////
////    let chat2 = Chat(context: CDClient.mainManagedObjectContext)
////    chat2.text = "Another chat text"
////    chat2.conversation = conversation
////
////    try? CDClient.mainManagedObjectContext.save()
//
//    return EntryView(
//        noUserChatsSent: false,
//        maxHeight: 400.0,
//        conversationChatGenerator: ConversationChatGenerator(),
//        onOpenAttachFile: {
//
//        },
//        onOpenCall: {
//
//        },
//        onSubmit: { text, image, imageURL in
//
//        })
//    .background(Colors.background)
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
////    .environmentObject(ConversationChatGenerator())
////    .environmentObject(PremiumUpdater())
////    .environmentObject(RemainingUpdater())
//}



////
////  EntryView.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 10/22/23.
////
//
//import SwiftUI
//
//struct EntryView: View, KeyboardReadable {
//    
//    @State var noUserChatsSent: Bool
//    let maxHeight: CGFloat
//    @ObservedObject var conversationChatGenerator: ConversationChatGenerator
//    let onOpenAttachFile: () -> Void
//    let onOpenCall: () -> Void
//    let onSubmit: (_ text: String, _ images: [UIImage], _ imageURLs: [String]) -> Void
//    
//    @Environment(\.colorScheme) private var colorScheme
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    private let cornerRadius = 14.0
//    
//    @State private var alertShowingUpgradeForFasterChats: Bool = false
//    
////    @State private var cameraViewCropFrame: CGRect?
////    @State private var cameraViewInitialImage: UIImage?
//    @State private var cameraViewImageData: ImageData?
//    
//    @State private var isDisplayingAttachmentButtons: Bool = true
//    @State private var isDisplayingPhotoPicker: Bool = false
//    
//    @State private var isShowingReviewModel: Bool = false
//    @State private var isShowingUltraView: Bool = false
//    
//    @State private var keyboardStatus: KeyboardStatus?
//    
//    @State private var text: String = ""
//    @State private var imageURLs: [String] = []
//    
//    // Updated to handle multiple images
//    @State private var imagesData: [ImageData] = []
//    
//    var buttonDisabled: Bool {
//        (text.isEmpty && imagesData.isEmpty && imageURLs.isEmpty) || conversationChatGenerator.isLoading
//    }
//    
//    var body: some View {
//        VStack {
//            let _ = Self._printChanges()
//            
//            // Image and Text Entry
//            HStack(alignment: .bottom, spacing: 12.0) {
//                EntryAttachmentButtons(
//                    cameraViewImageData: $cameraViewImageData,
//                    imagesData: $imagesData,
//                    isDisplayingAttachmentButtons: $isDisplayingAttachmentButtons,
//                    isDisplayingPhotoPicker: $isDisplayingPhotoPicker,
//                    onOpenAttachFile: onOpenAttachFile)
//                
//                EntryTextView(
//                    text: $text,
//                    imagesData: $imagesData,
//                    imageURLs: $imageURLs,
//                    cameraViewImageData: $cameraViewImageData,
//                    buttonDisabled: buttonDisabled,
//                    maxHeight: maxHeight,
//                    onSubmit: onSubmit)
//                
//                // Voice Chat
//                Button(action: onOpenCall) {
//                    Image(systemName: "person.wave.2.fill")
//                        .fontWeight(.bold)
//                        .foregroundStyle(Colors.userChatBubbleColor)
//                }
//                .frame(maxHeight: .infinity, alignment: .bottom)
//                .padding(.vertical, 12)
//                .disabled({if #available(iOS 17, *) { false } else { true }}())
//                .opacity({if #available(iOS 17, *) { 1.0 } else { 0.6 }}())
//            }
//            .foregroundStyle(Colors.text)
//            .fixedSize(horizontal: false, vertical: true)
//            .padding(.horizontal)
//        }
//        // Camera View
//        .fullScreenCover(item: $cameraViewImageData, content: { cameraViewImageData in
//            ZStack {
////                CaptureCameraViewControllerRepresentableContainer(
////                    reset: .constant(false),
////                    imageData: cameraViewImageData,
//////                    withCropFrame: cameraViewInitialImageData?.cropFrame,
//////                    withImage: cameraViewInitialImageData?.uncroppedImage ?? cameraViewInitialImageData?.image,
////                    onAttach: {
////                        if !self.imagesData.contains(where: {$0 === cameraViewImageData}) {
////                            imagesData.append(cameraViewImageData)
////                        }
////                        self.cameraViewImageData = nil
////                        self.imagesData.removeAll(where: {$0.image == nil})
////                    },
////                    onScan: { scanText in
////                        // Add scanText to text with a space if text is not empty
////                        text += text.isEmpty ? scanText : " " + scanText
////                        self.cameraViewImageData = nil
////                        self.imagesData.removeAll(where: {$0.image == nil})
////                    })
////                // TODO: Camera View
////                ImageCropTest()
//                
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            self.cameraViewImageData = nil
//                            self.imagesData.removeAll(where: {$0.image == nil})
//                        }) {
//                            Text(Image(systemName: "xmark"))
//                                .font(.custom(Constants.FontName.body, size: 20.0))
//                                .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
//                                .padding()
//                                .background(Colors.foreground)
//                                .clipShape(Circle())
//                        }
//                    }
//                    Spacer()
//                }
//            }
//        })
//        .clearFullScreenCover(isPresented: $conversationChatGenerator.isDisplayingPromoSendImagesView, content: {
//            PromoSendImagesView(isShowing: $conversationChatGenerator.isDisplayingPromoSendImagesView, pressedScan: {
//                // Dismiss
//                conversationChatGenerator.isDisplayingPromoSendImagesView = false
//                
//                // Reset camera view initial image and crop frame
//                cameraViewImageData = ImageData()
//                
////                // Show cameraView
////                isShowingCameraView = true
//            })
//        })
//        .imagePicker(
//            isPresented: $isDisplayingPhotoPicker,
//            onSelect: { image in
//                // Add image to imagesData
//                let imageData = ImageData(image: image, uncroppedImage: nil, cropFrame: nil)
//                imagesData.append(imageData)
//            })
//        .alert("Upgrade for FREE", isPresented: $alertShowingUpgradeForFasterChats, actions: {
//            Button("Cancel", role: nil, action: {})
//            Button("Start Free Trial", role: .cancel, action: {
//                isShowingUltraView = true
//            })
//        }) {
//            Text("Please upgrade to send chats faster. Good news... you can get this and GPT-4o for FREE!")
//        }
//        .onReceive(keyboardPublisher) { newValue in
//            DispatchQueue.main.async {
//                self.keyboardStatus = newValue
//            }
//        }
//        .onChange(of: keyboardStatus) { newValue in
//            if newValue == .willShow {
//                // If keyboard will show, hide attachment buttons
//                withAnimation {
//                    isDisplayingAttachmentButtons = false
//                }
//            } else if newValue == .willHide {
//                // If keyboard will hide, show attachment buttons
//                withAnimation {
//                    isDisplayingAttachmentButtons = true
//                }
//            }
//        }
//    }
//    
//}
//
//// Define ImageData struct to hold image-related data
//class ImageData: ObservableObject, Identifiable {
//    let id = UUID()
//    @Published var image: UIImage?
//    @Published var uncroppedImage: UIImage?
//    @Published var cropFrame: CGRect?
//    
//    init(image: UIImage? = nil, uncroppedImage: UIImage? = nil, cropFrame: CGRect? = nil) {
//        self.image = image
//        self.uncroppedImage = uncroppedImage
//        self.cropFrame = cropFrame
//    }
//}
//
////@available(iOS 17.0, *)
////#Preview(traits: .sizeThatFitsLayout) {
////    
//////    let conversation = Conversation(context: CDClient.mainManagedObjectContext)
//////    
//////    let chat1 = Chat(context: CDClient.mainManagedObjectContext)
//////    chat1.text = "Chat text"
//////    chat1.conversation = conversation
//////    
//////    let chat2 = Chat(context: CDClient.mainManagedObjectContext)
//////    chat2.text = "Another chat text"
//////    chat2.conversation = conversation
//////    
//////    try? CDClient.mainManagedObjectContext.save()
////    
////    return EntryView(
////        noUserChatsSent: false,
////        maxHeight: 400.0,
////        conversationChatGenerator: ConversationChatGenerator(),
////        onOpenAttachFile: {
////            
////        },
////        onOpenCall: {
////            
////        },
////        onSubmit: { text, image, imageURL in
////            
////        })
////    .background(Colors.background)
////    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//////    .environmentObject(ConversationChatGenerator())
//////    .environmentObject(PremiumUpdater())
//////    .environmentObject(RemainingUpdater())
////}
