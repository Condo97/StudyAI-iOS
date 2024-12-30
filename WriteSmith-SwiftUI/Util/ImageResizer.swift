//
//  ImageResizer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/10/24.
//

import Foundation
import UIKit

class ImageResizer {
    
    static func resizedJpegDataTo512(from imageData: Data) -> Data? {
        // Create a UIImage from the input data
        guard let image = UIImage(data: imageData) else {
            print("Error: Cannot create image from data")
            return nil
        }
        
        return resizedJpegDataTo512(from: image)
    }
    
    static func resizedJpegDataTo512(from image: UIImage) -> Data? {
        // Calculate the new size to maintain aspect ratio
        let aspectWidth = 512 / image.size.width
        let aspectHeight = 512 / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)

        // Create UIGraphics context with new size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Convert the resized image back to data
        guard let newImageData = resizedImage?.jpegData(compressionQuality: 0.85) else {
            print("Error: Cannot convert resized image back to Data")
            return nil
        }

        return newImageData
    }
    
}
