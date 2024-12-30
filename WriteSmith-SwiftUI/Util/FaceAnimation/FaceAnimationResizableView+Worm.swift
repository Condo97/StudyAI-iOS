//
//  FaceAnimationResizableView+Worm.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/24/24.
//

import FaceAnimation
import Foundation
import UIKit

extension FaceAnimationResizableView {
    
    static func worm(color: UIColor, startAnimation: FaceAnimation = FaceAnimationRepository.center(duration: 0.0), idleAnimations: [FaceAnimation] = RandomFaceIdleAnimationSequence.smile.animationSequence.animations) -> FaceAnimationResizableView {
        FaceAnimationResizableView(
            eyesImageName: FaceStyles.worm.eyesImageName,
            mouthImageName: FaceStyles.worm.mouthImageName,
            noseImageName: FaceStyles.worm.noseImageName,
            faceImageName: FaceStyles.worm.backgroundImageName,
            facialFeaturesScaleFactor: 0.72,
            eyesPositionFactor: FaceStyles.worm.eyesPositionFactor,
            faceRenderingMode: FaceStyles.worm.faceRenderingMode,
            color: color,//UIColor(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor),
            startAnimation: startAnimation,
            idleAnimations: idleAnimations)
    }
    
}
