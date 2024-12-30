//
//  DeselectedFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/12/23.
//

import FaceAnimation
import Foundation

struct DeselectedFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        FaceAnimationRepository.center(duration: 0.4),
        FaceAnimationRepository.waitAnimation(duration: 7.0)
    ]
    
}
