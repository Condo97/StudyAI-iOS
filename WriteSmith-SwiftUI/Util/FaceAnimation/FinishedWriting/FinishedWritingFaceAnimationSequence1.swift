//
//  FinishedWritingFaceAnimationSequence1.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

struct FinishedWritingFaceAnimationSequence1: FaceAnimationSequence {
    
    var animations: [FaceAnimation] = [
        FaceAnimationRepository.finishedWriting1(),
        FaceAnimationRepository.waitAnimation(duration: 0.4)
    ]
    
}
