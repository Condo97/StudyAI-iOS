//
//  SmileIdleFaceAnimationSequence2.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/4/24.
//

import FaceAnimation
import Foundation

struct SmileIdleFaceAnimationSequence2: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        FaceAnimationRepository.center(duration: 0.4),
        FaceAnimationRepository.waitAnimation(duration: 1.0),
        FaceAnimationRepository.lookUp(duration: 0.6),
        FaceAnimationRepository.waitAnimation(duration: 0.4),
        FaceAnimationRepository.center(duration: 0.4),
        FaceAnimationRepository.waitAnimation(duration: 3.0)
    ]
    
}
