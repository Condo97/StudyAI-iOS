//
//  FaceStagnantViewRepresentable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/26/24.
//

import FaceAnimation
import SwiftUI
import UIKit

public struct FaceStagnantViewRepresentable: UIViewRepresentable {
    
    @State var blink: Bool = false
    @State var color: UIColor
    
    public var frame: CGRect
    public var showsMouth: Bool
    public var eyesImageName: String
    public var mouthImageName: String
    public var noseImageName: String
    public var faceImageName: String
    public var facialFeaturesScaleFactor: CGFloat
    public var eyesPositionFactor: CGFloat
    public var faceRenderingMode: UIImage.RenderingMode
    public var stagnantAnimation: FaceAnimation?
    
    
//    private var faceAnimationView: FaceAnimationView
    
    @State private var isRandomBlinkRunning: Bool = false
    
    private let randomBlinkSecondsMin: UInt64 = 2
    private let randomBlinkSecondsMax: UInt64 = 12
    
    public init(frame: CGRect, showsMouth: Bool, eyesImageName: String, mouthImageName: String, noseImageName: String, faceImageName: String, facialFeaturesScaleFactor: CGFloat, eyesPositionFactor: CGFloat, faceRenderingMode: UIImage.RenderingMode, color: UIColor, stagnantAnimation: FaceAnimation? = nil) {
        self.frame = frame
        self.showsMouth = showsMouth
        self.eyesImageName = eyesImageName
        self.mouthImageName = mouthImageName
        self.noseImageName = noseImageName
        self.faceImageName = faceImageName
        self.facialFeaturesScaleFactor = facialFeaturesScaleFactor
        self.eyesPositionFactor = eyesPositionFactor
        self.faceRenderingMode = faceRenderingMode
        self.stagnantAnimation = stagnantAnimation
        self._color = State(initialValue: color)
        
//        self.faceAnimationView = FaceAnimationView(
//            frame: frame,
//            showsMouth: showsMouth,
//            noseImageName: noseImageName,
//            faceImageName: faceImageName,
//            facialFeaturesScaleFactor: facialFeaturesScaleFactor,
//            startAnimation: stagnantAnimation)
//        self.faceAnimationView.tintColor = color
        
        startRandomBlink()
    }
    
    public func makeUIView(context: Context) -> FaceAnimationView {
        let faceAnimationView = FaceAnimationView(
            frame: frame,
//            showsMouth: showsMouth,
            eyesImageName: eyesImageName,
            mouthImageName: mouthImageName,
            noseImageName: noseImageName,
            faceImageName: faceImageName,
            facialFeaturesScaleFactor: facialFeaturesScaleFactor,
            eyesPositionFactor: eyesPositionFactor,
            faceRenderingMode: faceRenderingMode,
            startAnimation: stagnantAnimation)
        
        faceAnimationView.tintColor = color
        
        return faceAnimationView
    }
    
    public func updateUIView(_ uiView: FaceAnimationView, context: Context) {
        uiView.frame = frame
        uiView.tintColor = color
        
        uiView.setNeedsLayout()
        uiView.layoutIfNeeded()
        
        if blink {
            uiView.async(faceAnimation: FaceAnimationRepository.blinkFaceAnimation)
            
            blink = false
        }
    }
    
    public func startRandomBlink() {
        // Blink after random seconds, between 4 and 12
        Task {
            // TODO: Is it okay to do a while true here?
            while true {
                await blinkAfterRandomSeconds()
            }
        }
    }
    
    public func blinkAfterRandomSeconds() async {
        do {
            try await Task.sleep(nanoseconds: UInt64.random(in: randomBlinkSecondsMin...randomBlinkSecondsMax) * 1_000_000_000)
        } catch {
            print("Error sleeping Task when blinking after random seconds in GlobalTabBarFaceController... \(error)")
        }
        
        blink = true
    }
    
    public func setColor(_ color: UIColor) {
        DispatchQueue.main.async {
            self.color = color
        }
    }
    
}

//#Preview {
//    ZStack {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                FaceAnimationViewRepresentable(
//                    frame: CGRect(x: 0, y: 0, width: 200, height: 200),
//                    eyesImageName: "Man Eyes",
//                    mouthImageName: "Man Mouth",
//                    noseImageName: "WriteSmith Original Nose",
//                    faceImageName: "WriteSmith Original Background",
//                    facialFeaturesScaleFactor: 2.0,
//                    eyesPositionFactor: 2.0/5.0,
//                    faceRenderingMode: .alwaysTemplate,
//                    color: .aiChatBubble,
//                    startAnimation: FaceAnimationRepository.center(duration: 0.0)
//                )
//                .frame(width: 200, height: 200)
//                .background(.green)
//                Spacer()
//            }
//            Spacer()
//        }
//    }
//}
//
