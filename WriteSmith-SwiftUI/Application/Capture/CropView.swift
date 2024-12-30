//
//  CropView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/8/24.
//

import SwiftUI
import Vision

struct ImageCropTest: View {
    // Binding for the crop rectangle
    @State private var cropRect: CGRect = CGRect.zero

    var body: some View {
        ImageCropView(cropRect: $cropRect, uiImage: UIImage(named: "sample_image")!)
            .onAppear {
                // Initialize the crop rectangle when the view appears
                // The cropRect is set to the middle half of the image
                // Adjust these values as needed
                cropRect = CGRect.zero
            }
    }
}

struct ImageCropView: View {
    @Binding var cropRect: CGRect
    var uiImage: UIImage

    var body: some View {
        GeometryReader { geometry in
            let geometrySize = geometry.size
            let imageSize = uiImage.size
            let imageAspectRatio = imageSize.width / imageSize.height
            let viewAspectRatio = geometrySize.width / geometrySize.height

            var displayImageSize: CGSize {
                var displayImageSize = CGSize()
                if imageAspectRatio > viewAspectRatio {
                    // Image is wider than the view
                    displayImageSize.width = geometrySize.width
                    displayImageSize.height = geometrySize.width / imageAspectRatio
                } else {
                    displayImageSize.width = geometrySize.height * imageAspectRatio
                    displayImageSize.height = geometrySize.height
                }
                return displayImageSize
            }
            var imageOrigin: CGPoint {
                var imageOrigin = CGPoint()
                if imageAspectRatio > viewAspectRatio {
                    imageOrigin.x = 0
                    imageOrigin.y = (geometrySize.height - displayImageSize.height) / 2
                } else {
                    imageOrigin.x = (geometrySize.width - displayImageSize.width) / 2
                    imageOrigin.y = 0
                }
                return imageOrigin
            }

            let displayedImageRect = CGRect(origin: imageOrigin, size: displayImageSize)

            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometrySize.width, height: geometrySize.height)
                    .clipped()

                CropOverlayView(cropRect: $cropRect, imageRect: displayedImageRect)
            }
            .onAppear {
                // Initialize the cropRect to be centered with 100x100 size
                if cropRect == .zero {
                    let width: CGFloat = 100
                    let height: CGFloat = 100
                    let x = displayedImageRect.midX - width / 2
                    let y = displayedImageRect.midY - height / 2
                    cropRect = CGRect(x: x, y: y, width: width, height: height)
                }
            }
        }
    }
}

struct CropOverlayView: View {
    @Binding var cropRect: CGRect
    var imageRect: CGRect

    var body: some View {
        ZStack {
            // Dimming overlay
            DimmingOverlay(cropRect: cropRect, imageRect: imageRect)

            // Crop rectangle border
            Rectangle()
                .path(in: cropRect)
                .stroke(Color.white, lineWidth: 2)

            // Corner handles
            CornerHandles(cropRect: $cropRect, imageRect: imageRect)
        }
    }
}

struct DimmingOverlay: View {
    var cropRect: CGRect
    var imageRect: CGRect

    var body: some View {
        Color.black.opacity(0.5)
            .mask(
                Path { path in
                    path.addRect(CGRect(origin: .zero, size: UIScreen.main.bounds.size))
                    path.addRect(cropRect)
                }
                .fill(style: FillStyle(eoFill: true))
            )
    }
}

struct CornerHandles: View {
    @Binding var cropRect: CGRect
    var imageRect: CGRect
    let handleSize: CGFloat = 30.0

    // State variable to store the initial crop rectangle during a drag
    @State private var initialCropRect: CGRect?

    var body: some View {
        ZStack {
            // Top-left handle
            HandleView()
                .position(x: cropRect.minX, y: cropRect.minY)
                .gesture(dragGesture(for: .topLeft))

            // Top-right handle
            HandleView()
                .position(x: cropRect.maxX, y: cropRect.minY)
                .gesture(dragGesture(for: .topRight))

            // Bottom-left handle
            HandleView()
                .position(x: cropRect.minX, y: cropRect.maxY)
                .gesture(dragGesture(for: .bottomLeft))

            // Bottom-right handle
            HandleView()
                .position(x: cropRect.maxX, y: cropRect.maxY)
                .gesture(dragGesture(for: .bottomRight))
        }
    }

    func dragGesture(for corner: Corner) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Store the initial crop rectangle when the drag starts
                if initialCropRect == nil {
                    initialCropRect = cropRect
                }
                updateCropRect(for: corner, with: value, initialRect: initialCropRect!)
            }
            .onEnded { _ in
                // Reset the initial crop rectangle when the drag ends
                initialCropRect = nil
            }
    }

    func updateCropRect(for corner: Corner, with value: DragGesture.Value, initialRect: CGRect) {
        let translation = value.translation
        var newRect = initialRect

        switch corner {
        case .topLeft:
            newRect.origin.x += translation.width
            newRect.origin.y += translation.height
            newRect.size.width -= translation.width
            newRect.size.height -= translation.height
        case .topRight:
            newRect.size.width += translation.width
            newRect.origin.y += translation.height
            newRect.size.height -= translation.height
        case .bottomLeft:
            newRect.origin.x += translation.width
            newRect.size.width -= translation.width
            newRect.size.height += translation.height
        case .bottomRight:
            newRect.size.width += translation.width
            newRect.size.height += translation.height
        }

        // Enforce constraints to keep the crop rectangle within bounds
        cropRect = enforceConstraints(for: newRect, corner: corner)
    }

    func enforceConstraints(for rect: CGRect, corner: Corner) -> CGRect {
        var newRect = rect

        let minWidth: CGFloat = 50
        let minHeight: CGFloat = 50

        // Ensure the cropRect doesn't go outside the imageRect
        newRect.origin.x = max(newRect.origin.x, imageRect.origin.x)
        newRect.origin.y = max(newRect.origin.y, imageRect.origin.y)

        if newRect.maxX > imageRect.maxX {
            newRect.size.width = imageRect.maxX - newRect.origin.x
        }
        if newRect.maxY > imageRect.maxY {
            newRect.size.height = imageRect.maxY - newRect.origin.y
        }

        // Enforce minimum size and adjust origin if necessary
        if newRect.width < minWidth {
            newRect.size.width = minWidth
            if corner == .topLeft || corner == .bottomLeft {
                newRect.origin.x = cropRect.maxX - minWidth
            }
        }
        if newRect.height < minHeight {
            newRect.size.height = minHeight
            if corner == .topLeft || corner == .topRight {
                newRect.origin.y = cropRect.maxY - minHeight
            }
        }

        return newRect
    }
}

enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
}

struct HandleView: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 30, height: 30)
            .shadow(radius: 2)
    }
}

//struct CropView: View {
//    
//    @State private var image: UIImage = UIImage(named: "sample_image")! // Replace with your image
//    @State private var cropRect: CGRect = .zero
//    @State private var isCropped: Bool = false
//    @State private var croppedImage: UIImage?
//    @State private var imageSize: CGSize = .zero
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                GeometryReader { geometry in
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                        .overlay(
//                            CropOverlayView(cropRect: $cropRect,
//                                            imageSize: $imageSize,
//                                            parentSize: geometry.size)
//                        )
//                        .onAppear {
//                            self.imageSize = calculateImageDisplaySize(image: image, inSize: geometry.size)
//                            detectText(in: image) { rect in
//                                if let rect = rect {
//                                    // Convert image coordinates to SwiftUI coordinate space
//                                    let scaledRect = convertImageRectToViewRect(rect: rect, imageSize: image.size, viewSize: imageSize)
//                                    self.cropRect = scaledRect
//                                } else {
//                                    // Default to full image if text detection fails
//                                    self.cropRect = CGRect(origin: .zero, size: imageSize)
//                                }
//                            }
//                        }
//                }
//                if isCropped, let croppedImg = croppedImage {
//                    Color.black.opacity(0.5)
//                        .edgesIgnoringSafeArea(.all)
//                    Image(uiImage: croppedImg)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 300, height: 300)
//                }
//            }
//            .navigationBarTitle("Crop Image", displayMode: .inline)
//            .navigationBarItems(trailing:
//                Button(action: {
//                    if let croppedImg = cropImage(image: image, toRect: cropRect, imageDisplaySize: imageSize) {
//                        self.croppedImage = croppedImg
//                        self.isCropped = true
//                    }
//                }) {
//                    Text("Crop")
//                }
//            )
//        }
//    }
//    
//}
//
//struct CropOverlayView: View {
//    
//    @Binding var cropRect: CGRect
//    @Binding var imageSize: CGSize
//    var parentSize: CGSize
//
//    @State private var isDragging: Bool = false
//    @State private var lastDragPosition: CGPoint?
//
//    var body: some View {
//        ZStack {
//            // Mask outside the crop rect
//            if #available(iOS 17.0, *) {
//                Rectangle()
//                    .fill(Color.black.opacity(0.5))
//                    .frame(width: parentSize.width, height: parentSize.height)
//                    .mask(
//                        Rectangle()
//                            .path(in: CGRect(origin: .zero, size: parentSize))
////                            .subtracting(
////                                Rectangle()
////                                    .path(in: cropRect)
////                            )
//                    )
//                    .allowsHitTesting(false)
//            } else {
//                // Fallback on earlier versions
//            }
//
//            // Crop rectangle border
//            Rectangle()
//                .stroke(Color.yellow, lineWidth: 2)
//                .frame(width: cropRect.width, height: cropRect.height)
//                .position(x: cropRect.midX, y: cropRect.midY)
//                .gesture(
//                    DragGesture()
//                        .onChanged { value in
//                            let translation = value.translation
//                            self.cropRect.origin.x += translation.width
//                            self.cropRect.origin.y += translation.height
//                            self.ensureCropRectWithinBounds()
//                        }
//                )
//
//            // Corner handles
//            Group {
//                // Top-left handle
//                Rectangle()
//                    .fill(Color.white)
//                    .frame(width: 20, height: 20)
//                    .position(x: cropRect.minX, y: cropRect.minY)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                let deltaX = value.location.x - cropRect.minX
//                                let deltaY = value.location.y - cropRect.minY
//                                cropRect.origin.x += deltaX
//                                cropRect.origin.y += deltaY
//                                cropRect.size.width -= deltaX
//                                cropRect.size.height -= deltaY
//                                self.ensureCropRectWithinBounds()
//                            }
//                    )
//
//                // Top-right handle
//                Rectangle()
//                    .fill(Color.white)
//                    .frame(width: 20, height: 20)
//                    .position(x: cropRect.maxX, y: cropRect.minY)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                let deltaX = value.location.x - cropRect.maxX
//                                let deltaY = value.location.y - cropRect.minY
//                                cropRect.size.width += deltaX
//                                cropRect.origin.y += deltaY
//                                cropRect.size.height -= deltaY
//                                self.ensureCropRectWithinBounds()
//                            }
//                    )
//
//                // Bottom-left handle
//                Rectangle()
//                    .fill(Color.white)
//                    .frame(width: 20, height: 20)
//                    .position(x: cropRect.minX, y: cropRect.maxY)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                let deltaX = value.location.x - cropRect.minX
//                                let deltaY = value.location.y - cropRect.maxY
//                                cropRect.origin.x += deltaX
//                                cropRect.size.width -= deltaX
//                                cropRect.size.height += deltaY
//                                self.ensureCropRectWithinBounds()
//                            }
//                    )
//
//                // Bottom-right handle
//                Rectangle()
//                    .fill(Color.white)
//                    .frame(width: 20, height: 20)
//                    .position(x: cropRect.maxX, y: cropRect.maxY)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                let deltaX = value.location.x - cropRect.maxX
//                                let deltaY = value.location.y - cropRect.maxY
//                                cropRect.size.width += deltaX
//                                cropRect.size.height += deltaY
//                                self.ensureCropRectWithinBounds()
//                            }
//                    )
//            }
//        }
//    }
//
//    private func ensureCropRectWithinBounds() {
//        // Ensure the crop rectangle stays within the image bounds
//        cropRect.origin.x = max(0, cropRect.origin.x)
//        cropRect.origin.y = max(0, cropRect.origin.y)
//        cropRect.size.width = min(parentSize.width - cropRect.origin.x, cropRect.size.width)
//        cropRect.size.height = min(parentSize.height - cropRect.origin.y, cropRect.size.height)
//        if cropRect.size.width < 50 {
//            cropRect.size.width = 50
//        }
//        if cropRect.size.height < 50 {
//            cropRect.size.height = 50
//        }
//    }
//    
//}
//
//func detectText(in image: UIImage, completion: @escaping (CGRect?) -> Void) {
//    guard let cgImage = image.cgImage else {
//        completion(nil)
//        return
//    }
//
//    let request = VNRecognizeTextRequest { (request, error) in
//        guard let observations = request.results as? [VNTextObservation] else {
//            completion(nil)
//            return
//        }
//
//        // Obtain the bounding boxes for all detected text
//        let boundingRects = observations.compactMap { observation -> CGRect? in
//            return observation.boundingBox
//        }
//
//        guard !boundingRects.isEmpty else {
//            completion(nil)
//            return
//        }
//
//        // Combine bounding boxes into one rectangle
//        let unionRect = boundingRects.reduce(CGRect.null) { $0.union($1) }
//
//        // Convert normalized coordinates to image coordinates
//        let imageRect = VNImageRectForNormalizedRect(unionRect, Int(image.size.width), Int(image.size.height))
//
//        completion(imageRect)
//    }
//
//    request.recognitionLevel = .accurate
//    request.recognitionLanguages = ["en-US"] // Set to your desired language
//    request.usesLanguageCorrection = true
//
//    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//    DispatchQueue.global(qos: .userInitiated).async {
//        do {
//            try requestHandler.perform([request])
//        } catch {
//            print("Failed to perform text detection: \(error)")
//            completion(nil)
//        }
//    }
//}
//
//// Function to calculate the size of the image as it's displayed
//func calculateImageDisplaySize(image: UIImage, inSize availableSize: CGSize) -> CGSize {
//    let imageAspectRatio = image.size.width / image.size.height
//    let containerAspectRatio = availableSize.width / availableSize.height
//    if imageAspectRatio > containerAspectRatio {
//        // Image is wider than the container
//        let width = availableSize.width
//        let height = width / imageAspectRatio
//        return CGSize(width: width, height: height)
//    } else {
//        // Image is taller than the container
//        let height = availableSize.height
//        let width = height * imageAspectRatio
//        return CGSize(width: width, height: height)
//    }
//}
//
//// Convert image coordinates to view coordinates
//func convertImageRectToViewRect(rect: CGRect, imageSize: CGSize, viewSize: CGSize) -> CGRect {
//    let scaleX = viewSize.width / imageSize.width
//    let scaleY = viewSize.height / imageSize.height
//
//    var newRect = rect
//    newRect.origin.x *= scaleX
//    newRect.origin.y *= scaleY
//    newRect.size.width *= scaleX
//    newRect.size.height *= scaleY
//
//    // Adjust for SwiftUI coordinate system (origin at top-left)
//    newRect.origin.y = viewSize.height - newRect.origin.y - newRect.size.height
//
//    return newRect
//}
//
//// Function to crop the image
//func cropImage(image: UIImage, toRect rect: CGRect, imageDisplaySize: CGSize) -> UIImage? {
//    guard let cgImage = image.cgImage else { return nil }
//
//    let scaleX = image.size.width / imageDisplaySize.width
//    let scaleY = image.size.height / imageDisplaySize.height
//
//    var cropZone = CGRect(x: rect.origin.x * scaleX,
//                          y: rect.origin.y * scaleY,
//                          width: rect.size.width * scaleX,
//                          height: rect.size.height * scaleY)
//
//    // Adjust for Core Graphics coordinate system (origin at bottom-left)
//    cropZone.origin.y = image.size.height - cropZone.origin.y - cropZone.size.height
//
//    guard let croppedCgImage = cgImage.cropping(to: cropZone) else { return nil }
//    let croppedImage = UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)
//    return croppedImage
//}
