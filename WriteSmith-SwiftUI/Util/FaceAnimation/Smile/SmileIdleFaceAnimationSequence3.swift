//
//  SmileIdleFaceAnimationSequence3.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/4/24.
//

import FaceAnimation
import Foundation

struct SmileIdleFaceAnimationSequence3: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        FaceAnimationRepository.center(duration: 0.4),
        FaceAnimationRepository.waitAnimation(duration: 2.0),
        FaceAnimationRepository.lookRight(duration: 0.6),
        FaceAnimationRepository.waitAnimation(duration: 0.6),
        FaceAnimationRepository.lookLeftCurve(duration: 0.6),
        FaceAnimationRepository.waitAnimation(duration: 0.6),
        FaceAnimationRepository.center(duration: 0.6),
        FaceAnimationRepository.waitAnimation(duration: 3.0)
    ]
    
}
