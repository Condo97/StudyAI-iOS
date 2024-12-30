//
//  SmileIdleFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct SmileIdleFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        FaceAnimationRepository.center(duration: 0.4),
//        SmileCenterFaceAnimation(duration: 0.4),
        FaceAnimationRepository.waitAnimation(duration: 1.0),
//        WaitFaceAnimation(duration: 1.0),
        FaceAnimationRepository.waitAnimation(duration: 1.0),
//        WaitFaceAnimation(duration: 1.0),
        FaceAnimationRepository.lookLeft(duration: 0.6),
//        SmileLookLeftFaceAnimation(),
        FaceAnimationRepository.waitAnimation(duration: 0.6),
//        WaitFaceAnimation(duration: 0.6),
        FaceAnimationRepository.lookRightCurve(duration: 0.6),
//        SmileLookRightCurveFaceAnimation(),
        FaceAnimationRepository.waitAnimation(duration: 0.6),
//        WaitFaceAnimation(duration: 0.6),
        FaceAnimationRepository.center(duration: 0.6),
//        SmileCenterFaceAnimation(duration: 0.6),
        FaceAnimationRepository.waitAnimation(duration: 1.0),
//        WaitFaceAnimation(duration: 1.0),
        FaceAnimationRepository.waitAnimation(duration: 1.0),
//        WaitFaceAnimation(duration: 1.0),
        FaceAnimationRepository.waitAnimation(duration: 1.0)
//        WaitFaceAnimation(duration: 1.0)
    ]
    
}
