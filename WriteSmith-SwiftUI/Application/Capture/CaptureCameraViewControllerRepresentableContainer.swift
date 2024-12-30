////
////  CaptureCameraViewControllerRepresentableContainer.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 10/6/24.
////
//
//import Foundation
//import SwiftUI
//
//struct CaptureCameraViewControllerRepresentableContainer: View {
//    
//    @Binding var reset: Bool
//    @ObservedObject var imageData: ImageData
//    var onAttach: () -> Void
//    
//    init(reset: Binding<Bool>, imageData: ImageData, onAttach: @escaping () -> Void) {
//        self._reset = reset
//        self.imageData = imageData
//        self.onAttach = onAttach
//    }
//    
//    var body: some View {
//        ScanProblemCameraView(onAttach: { image in
//            
//        })
////        CaptureCameraViewControllerRepresentable(
////            reset: $reset,
////            withCropFrame: $imageData.cropFrame,
////            withImage: $imageData.image,
////            onAttach: { image, cropFrame, uncroppedImage in
////                imageData.image = image
////                imageData.cropFrame = cropFrame
////                imageData.uncroppedImage = uncroppedImage
////                onAttach()
////            },
////            onScan: onScan)
//    }
//    
//}
//
//
