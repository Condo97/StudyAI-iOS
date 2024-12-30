//
//  ThinkingIdleFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct ThinkingIdleFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        FaceAnimationRepository.lookLeftCurve(duration: 0.6),
        FaceAnimationRepository.waitAnimation(duration: 1.0),
        FaceAnimationRepository.lookRightCurve(duration: 0.6),
        FaceAnimationRepository.waitAnimation(duration: 1.0)
    ]
    
}
