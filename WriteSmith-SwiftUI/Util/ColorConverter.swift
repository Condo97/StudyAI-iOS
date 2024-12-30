//
//  ColorConverter.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/26/24.
//

import Foundation
import UIKit

class ColorConverter {
    
    /// Converts a UIColor to a String representation.
    /// - Parameter color: The UIColor instance to be converted.
    /// - Returns: A String representing the color in RGBA format.
    static func string(from color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return "rgba(\(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)), \(alpha))"
    }
    
    /// Converts a String representation of a color back into a UIColor.
    /// - Parameter string: The String containing the RGBA formatted color.
    /// - Returns: A UIColor based on the string input, or nil if the conversion fails.
    static func color(from string: String) -> UIColor? {
        let components = string
            .replacingOccurrences(of: "rgba(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        
        guard components.count == 4,
              let red = components[safe: 0], red >= 0,
              let green = components[safe: 1], green >= 0,
              let blue = components[safe: 2], blue >= 0,
              let alpha = components[safe: 3], alpha >= 0 && alpha <= 1 else {
            return nil
        }
        
        return UIColor(red: CGFloat(red / 255.0),
                       green: CGFloat(green / 255.0),
                       blue: CGFloat(blue / 255.0),
                       alpha: CGFloat(alpha))
    }
}

