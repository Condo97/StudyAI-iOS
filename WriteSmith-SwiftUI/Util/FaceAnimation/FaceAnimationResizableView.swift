//
//  FaceAnimationResizableView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/24/24.
//

import FaceAnimation
import SwiftUI

struct FaceAnimationResizableView: View {
    
    public var eyesImageName: String
    public var mouthImageName: String
    public var noseImageName: String
    public var faceImageName: String
    public var facialFeaturesScaleFactor: CGFloat
    public var eyesPositionFactor: CGFloat
    public var faceRenderingMode: UIImage.RenderingMode
    public var color: UIColor
    public var startAnimation: FaceAnimation?
    public var queuedAnimations: [FaceAnimation] = []
    public var idleAnimations: [FaceAnimation] = []
    
    var body: some View {
        GeometryReader { geometry in
            FaceAnimationViewRepresentable(
                frame: CGRect(origin: .zero, size: geometry.size),
                eyesImageName: eyesImageName,
                mouthImageName: mouthImageName,
                noseImageName: noseImageName,
                faceImageName: faceImageName,
                facialFeaturesScaleFactor: facialFeaturesScaleFactor,
                eyesPositionFactor: eyesPositionFactor,
                faceRenderingMode: faceRenderingMode,
                color: color,
                startAnimation: startAnimation,
                queuedAnimations: queuedAnimations,
                idleAnimations: idleAnimations)
        }
    }
    
}

//#Preview {
//    
//    FaceAnimationResizableView(
//        eyesImageName: "Man Eyes",
//        mouthImageName: "Man Mouth",
//        noseImageName: "WriteSmith Original Nose",
//        faceImageName: "WriteSmith Original Background",
//        facialFeaturesScaleFactor: 0.76,
//        eyesPositionFactor: 2.0/5.0,
//        faceRenderingMode: .alwaysTemplate,
//        color: .aiChatBubble,
//        startAnimation: FaceAnimationRepository.center(duration: 0.0),
//        queuedAnimations: [FaceAnimationRepository.lookLeft(duration: 0.6), FaceAnimationRepository.waitAnimation(duration: 8.0)],
//        idleAnimations: RandomFaceIdleAnimationSequence.smile.animationSequence.animations
//    )
//    
//}
