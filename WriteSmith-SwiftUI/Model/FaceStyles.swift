//
//  FaceStyles.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/25/24.
//

import Foundation
import UIKit

enum FaceStyles {
    
//    case original
    case man
    case lady
    case worm
    case artist
    case genius
    case pal
    
    static func from(id: String) -> FaceStyles {
        switch id {
//        case FaceStyles.original.name: FaceStyles.original
        case FaceStyles.man.id: FaceStyles.man
        case FaceStyles.lady.id: FaceStyles.lady
        case FaceStyles.worm.id: FaceStyles.worm
        case FaceStyles.artist.id: FaceStyles.artist
        case FaceStyles.genius.id: FaceStyles.genius
        case FaceStyles.pal.id: FaceStyles.pal
        default: FaceStyles.worm//FaceStyles.original
        }
    }
    
    var id: String {
        switch self {
        case .man: "man"
        case .lady: "lady"
        case .worm: "worm"
        case .artist: "artist"
        case .genius: "genius"
        case .pal: "pal"
        }
    }
    
    var displayName: String {
        switch self {
//        case .original: "original"
        case .man: "Study AI"
        case .lady: "Study AI"
        case .worm: "Study AI"
        case .artist: "Artist"
        case .genius: "Genius"
        case .pal: "P.A.L."
        }
    }
    
    var nameLegacy: String {
        switch self {
//        case .original: "original"
        case .man: "Prof. Write"
        case .lady: "Prof. Wanda"
        case .worm: "Prof. Worm"
        case .artist: "Artist"
        case .genius: "Genius"
        case .pal: "P.A.L."
        }
    }
    
//    var showsMouth: Bool {
//        switch self {
////        case .original: true
//        case .man: true
//        case .lady: true
//        case .worm: true
//        case .artist: true
//        case .genius: false
//        case .pal: false
//        }
//    }
    
    var eyesImageName: String {
        switch self {
        case .man: "Man Eyes"
        case .lady: "Lady Eyes"
        case .worm: "Worm Eyes"
        case .artist: "Artist Eyes"
        case .genius: "Genius Eyes"
        case .pal: "PAL Eyes"
        }
    }
    
    var mouthImageName: String {
        switch self {
        case .man: "Man Mouth"
        case .lady: "Lady Mouth"
        case .worm: "Worm Mouth"
        case .artist: "Artist Mouth"
        case .genius: "Genius Mouth"
        case .pal: "PAL Mouth"
        }
    }
    
    var noseImageName: String {
        switch self {
//        case .original: "WriteSmith Original Nose"
        case .man: "Man Nose"
        case .lady: "Lady Nose"
        case .worm: "Worm Nose"
        case .artist: "Artist Nose"
        case .genius: "Genius Nose"
        case .pal: "PAL Nose"
        }
    }
    
    var backgroundImageName: String {
        switch self {
//        case .original: "WriteSmith Original Background"
        case .man: "Man Background"
        case .lady: "Lady Background"
        case .worm: "Worm Background"
        case .artist: "Artist Background"
        case .genius: "Genius Background"
        case .pal: "PAL Background"
        }
    }
    
    var staticImageName: String {
        switch self {
//        case .original: "WriteSmith Original Static"
        case .man: "Man Static"
        case .lady: "Lady Static"
        case .worm: "Worm Static"
        case .artist: "Artist Static"
        case .genius: "Genius Static"
        case .pal: "PAL Static"
        }
    }
    
    var eyesPositionFactor: CGFloat {
        switch self {
        case .man: 2.0/5.0
        case .lady: 2.0/5.0
        case .worm: 1.0/3.0
        case .artist: 2.0/5.0
        case .genius: 2.0/5.0
        case .pal: 2.0/5.0
        }
    }
    
    var faceRenderingMode: UIImage.RenderingMode {
        switch self {
        case .man: .alwaysTemplate
        case .lady: .alwaysTemplate
        case .worm: .alwaysOriginal
        case .artist: .alwaysTemplate
        case .genius: .alwaysTemplate
        case .pal: .alwaysTemplate
        }
    }
    
}
