////
////  UIImage+MostProminentColor.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 3/26/24.
////
//
//import Foundation
//import UIKit
//
//extension UIImage {
//    
//    func mostProminentColor() -> UIColor? {
//        // Resize image to reduce computation
//        let size = CGSize(width: 40, height: 40)
//        guard let resizedImage = self.resizedImage(to: size) else { return nil }
//        
//        guard let cgImage = resizedImage.cgImage else { return nil }
//        let width = cgImage.width
//        let height = cgImage.height
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bytesPerPixel = 4
//        let bytesPerRow = bytesPerPixel * width
//        let bitsPerComponent = 8
//        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
//        let context = CGContext(data: &pixelData,
//            width: width,
//            height: height,
//            bitsPerComponent: bitsPerComponent,
//            bytesPerRow: bytesPerRow,
//            space: colorSpace,
//            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
//
//        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//
//        var colorCountMap = [UIColor: Int]()
//
//        for x in 0..<width {
//            for y in 0..<height {
//                let offset = (y * width + x) * bytesPerPixel
//                let red = pixelData[offset]
//                let green = pixelData[offset + 1]
//                let blue = pixelData[offset + 2]
//                let alpha = pixelData[offset + 3]
//                
//                guard alpha > 0 else {
//                    continue
//                }
//                
//                let color = UIColor(red: CGFloat(red) / 255.0,
//                                    green: CGFloat(green) / 255.0,
//                                    blue: CGFloat(blue) / 255.0,
//                                    alpha: CGFloat(alpha) / 255.0)
//
//                if let count = colorCountMap[color] {
//                    colorCountMap[color] = count + 1
//                } else {
//                    colorCountMap[color] = 1
//                }
//            }
//        }
//
//        return colorCountMap.max { a, b in a.value < b.value }?.key
//    }
//
//    func resizedImage(to size: CGSize) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        draw(in: CGRect(origin: .zero, size: size))
//        let result = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return result
//    }
//    
//}
