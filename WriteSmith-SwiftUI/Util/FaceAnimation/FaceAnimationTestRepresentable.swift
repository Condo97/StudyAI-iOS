//
//  FaceAnimationRepresentable.swift
//
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import FaceAnimation
import SwiftUI
import UIKit

public struct FaceAnimationViewRepresentable: UIViewRepresentable {
    
    public var frame: CGRect
    public var eyesImageName: String
    public var mouthImageName: String
    public var noseImageName: String
    public var faceImageName: String
    public var facialFeaturesScaleFactor: CGFloat
    public var eyesPositionFactor: CGFloat
    public var faceRenderingMode: UIImage.RenderingMode
    public var color: UIColor
    public var startAnimation: FaceAnimation?
    public var queuedAnimations: [FaceAnimation]
    public var idleAnimations: [FaceAnimation]

    // Store the last queued animations to compare
    @State private var previousQueuedAnimations: [FaceAnimation] = []

    private let randomBlinkSecondsMin: UInt64 = 2
    private let randomBlinkSecondsMax: UInt64 = 12
    @State private var isRandomBlinkRunning: Bool = false

    public init(frame: CGRect, eyesImageName: String, mouthImageName: String, noseImageName: String, faceImageName: String, facialFeaturesScaleFactor: CGFloat, eyesPositionFactor: CGFloat, faceRenderingMode: UIImage.RenderingMode, color: UIColor, startAnimation: FaceAnimation? = nil, queuedAnimations: [FaceAnimation] = [], idleAnimations: [FaceAnimation] = []) {
        self.frame = frame
        self.eyesImageName = eyesImageName
        self.mouthImageName = mouthImageName
        self.noseImageName = noseImageName
        self.faceImageName = faceImageName
        self.facialFeaturesScaleFactor = facialFeaturesScaleFactor
        self.eyesPositionFactor = eyesPositionFactor
        self.faceRenderingMode = faceRenderingMode
        self.color = color
        self.startAnimation = startAnimation
        self.queuedAnimations = queuedAnimations
        self.idleAnimations = idleAnimations
    }
    
    public func makeUIView(context: Context) -> FaceAnimationView {
        let faceAnimationView = FaceAnimationView(
            frame: frame,
            eyesImageName: eyesImageName,
            mouthImageName: mouthImageName,
            noseImageName: noseImageName,
            faceImageName: faceImageName,
            facialFeaturesScaleFactor: facialFeaturesScaleFactor,
            eyesPositionFactor: eyesPositionFactor,
            faceRenderingMode: faceRenderingMode,
            startAnimation: startAnimation
        )

        faceAnimationView.tintColor = color
        
        // Initially set idle and queued animations
        if !idleAnimations.isEmpty {
            faceAnimationView.setIdleAnimations(idleAnimations)
        }
        
        if !queuedAnimations.isEmpty {
            faceAnimationView.queue(faceAnimations: queuedAnimations)
            previousQueuedAnimations = queuedAnimations // Store the initial queued animations
        }
        
        startRandomBlink()
        
        return faceAnimationView
    }
    
    public func updateUIView(_ uiView: FaceAnimationView, context: Context) {
        uiView.frame = frame
        uiView.tintColor = color
        uiView.eyesImageName = eyesImageName
        uiView.mouthImageName = mouthImageName
        uiView.noseImageName = noseImageName
        uiView.faceImageName = faceImageName
        
        // Only queue animations if they have changed
        if queuedAnimations != previousQueuedAnimations {
            uiView.queue(faceAnimations: queuedAnimations)
            previousQueuedAnimations = queuedAnimations // Update to the new queued animations
        }
        
        // Update idle animations if they have changed
        if idleAnimations != uiView.getIdleAnimations() {
            uiView.setIdleAnimations(idleAnimations)
        }
    }
    
    private func startRandomBlink() {
        // Only start one blink task
        guard !isRandomBlinkRunning else { return }
        
        isRandomBlinkRunning = true
        Task {
            while true {
                await blinkAfterRandomSeconds()
            }
        }
    }
    
    private func blinkAfterRandomSeconds() async {
        do {
            try await Task.sleep(nanoseconds: UInt64.random(in: randomBlinkSecondsMin...randomBlinkSecondsMax) * 1_000_000_000)
            blink()
        } catch {
            print("Error sleeping Task when blinking: \(error)")
        }
    }
    
    private func blink() {
        DispatchQueue.main.async {
            // You might want to keep a reference to the `FaceAnimationView`
            if let faceAnimationView = UIApplication.shared.windows.first?.rootViewController?.view as? FaceAnimationView {
                faceAnimationView.async(faceAnimation: FaceAnimationRepository.blinkFaceAnimation)
            }
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
//                    facialFeaturesScaleFactor: 0.76,
//                    eyesPositionFactor: 2.0/5.0,
//                    faceRenderingMode: .alwaysTemplate,
//                    color: .aiChatBubble,
//                    startAnimation: FaceAnimationRepository.center(duration: 0.0),
//                    queuedAnimations: [FaceAnimationRepository.lookLeft(duration: 0.6), FaceAnimationRepository.waitAnimation(duration: 8.0)],
//                    idleAnimations: RandomFaceIdleAnimationSequence.smile.animationSequence.animations
//                )
//                .frame(width: 200, height: 200)
//                .background(.green)
//                Spacer()
//            }
//            Spacer()
//        }
//    }
//}

