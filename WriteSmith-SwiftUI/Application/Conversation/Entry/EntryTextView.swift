////
////  EntryTextView.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 10/6/24.
////
//
//import SwiftUI
//
//struct EntryTextView: View {
//    
//    @Binding var text: String
//    @Binding var imagesData: [ImageData]
//    @Binding var imageURLs: [String]
//    @Binding var cameraViewImageData: ImageData?
//    let buttonDisabled: Bool
//    let maxHeight: CGFloat
//    let onSubmit: (_ text: String, _ images: [UIImage], _ imageURLs: [String]) -> Void
//    
//    @Environment(\.colorScheme) private var colorScheme
//    
//    var body: some View {
//        // Text entry
//        VStack(alignment: .leading) {
//            // Display attached images in a scroll view
//            if !imagesData.isEmpty {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(imagesData) { imageData in
//                            if let image = imageData.image {
//                                ZStack(alignment: .topTrailing) {
//                                    Button(action: {
//                                        // Set initial image and crop frame for editing
//                                        DispatchQueue.main.async {
//                                            cameraViewImageData = imageData
//                                        }
//                                    }) {
//                                        Image(uiImage: image)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(maxHeight: 120.0)
//                                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//                                    
//                                    // Close button to remove image
//                                    Button(action: {
//                                        withAnimation(.spring) {
//                                            imagesData.removeAll { $0.id == imageData.id }
//                                        }
//                                    }) {
//                                        Image(systemName: "xmark.circle.fill")
//                                            .font(.system(size: 20))
//                                            .foregroundColor(.white)
//                                    }
//                                    .offset(x: -5, y: 5)
//                                }
//                            }
//                        }
//                    }
////                            .padding(.vertical, 8)
//                    .padding(4)
//                    .padding(.horizontal, 8)
//                }
//            }
//            
//            HStack(alignment: .bottom) {
//                // Entry Text Field
//                TextField("", text: $text, axis: .vertical)
//                    .textFieldTickerTint(Colors.elementTextColor)
//                    .placeholder(when: text.isEmpty, placeholder: {
//                        Text("Message")
//                            .font(.custom(Constants.FontName.medium, size: 17.0))
//                            .opacity(0.6)
//                    })
//                    .dismissOnReturn()
//                    .font(.custom(Constants.FontName.body, size: 17.0))
//                    .padding(.leading, 8)
//                
//                // Entry Submit Button
//                KeyboardDismissingButton(action: {
//                    // Call onSubmit
//                    onSubmit(text, imagesData.compactMap { $0.image }, imageURLs)
//                    
//                    // Reset fields
//                    text = ""
//                    imagesData = []
//                    imageURLs = []
//                }) {
//                    Image(systemName: "arrow.up.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(height: 24.0)
//                        .foregroundStyle(colorScheme == .dark ? Colors.elementTextColor : Colors.userChatBubbleColor)
//                }
//                .disabled(buttonDisabled)
//                .opacity(buttonDisabled ? 0.2 : 1.0)
//            }
//            .padding(.horizontal, 8)
//        }
//        .frame(maxHeight: maxHeight)
//        .padding(.vertical, 8)
//        .clipShape(RoundedRectangle(cornerRadius: 28.0))
//        .background(RoundedRectangle(cornerRadius: 28.0)
//            .stroke(Colors.text.opacity(0.2), lineWidth: 1.0))
//        .onChange(of: buttonDisabled, perform: { value in
//            print("Button disabled state changed: \(value)")
//        })
//    }
//    
//}
//
////#Preview {
////    
////    EntryTextView()
////
////}
