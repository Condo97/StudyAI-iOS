//
//  AttachImageButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import SwiftUI

struct AttachImageButton: View {
    
    @Binding var imageDocumentsFilepath: String?
    var subtitle: LocalizedStringKey// = "Snap or upload an image to talk about it with AI."
//    @Binding var image: UIImage?
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var resetCaptureCameraView = false
    
    @State private var isShowingCameraView = false
    
    @State private var alertShowingErrorAttachingImage: Bool = false
    
    @State private var attachedImage: UIImage?
    
    
    var body: some View {
        Button(action: {
            isShowingCameraView = true
        }) {
            VStack {
                HStack {
//                    Text(Image(systemName: "camera"))
                    Text("📸")
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        .padding(4)
                        .frame(width: 38.0, height: 38.0)
                        .background(Colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                    Text("Image")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                HStack {
                    Text(subtitle)
                        .font(.custom(Constants.FontName.body, size: 10.0))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $isShowingCameraView, content: {
            ZStack {
                CaptureCameraViewControllerRepresentable(
                    reset: $resetCaptureCameraView,
                    withCropFrame: .constant(nil),
                    withImage: .constant(nil),
                    onAttach: { image, cropFrame, unmodifiedImage in
                        DispatchQueue.main.async {
                            self.attachedImage = image
                            self.isShowingCameraView = false
                        }
                    })
                
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
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .ignoresSafeArea()
        })
        .alert("Error Attaching Image", isPresented: $alertShowingErrorAttachingImage, actions: {
            Button("Close", action: {
                
            })
        }) {
            Text("There was an error attaching your image. Please try again.")
        }
        .onChange(of: attachedImage) { newValue in
            // Ensure unwrap image, otherwise show alert
            guard let newValue = newValue else {
                alertShowingErrorAttachingImage = true
                return
            }
            
            // Save image with name as UUID to DocumentsSaver
            let imageName = UUID().uuidString
            
            do {
                try DocumentSaver.save(newValue, to: imageName)
            } catch {
                // TODO: Handle Errors if Necessary
                print("Error saving image to DocumentSaver in AttachmentsView... \(error)")
                alertShowingErrorAttachingImage = true
                return
            }
            
            // Set imageDocumentsFilepath to imageName
            self.imageDocumentsFilepath = imageName
        }
    }
    
}

//#Preview {
//    AttachImageButton(
//        imageDocumentsFilepath: .constant(""),
//        subtitle: "Snap or upload an image to talk about it with AI.")
//}
