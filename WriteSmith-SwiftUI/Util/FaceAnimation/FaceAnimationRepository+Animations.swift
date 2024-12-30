//
//  SmileCenterFaceAnimation.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 9/10/23.
//

import FaceAnimation
import Foundation

extension FaceAnimationRepository {
    
    static func center(duration: CFTimeInterval) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withLinearAnimation: zeroPositionMoveAnimation,
            duration: duration)
    }
    
    static func lookLeft(duration: CFTimeInterval) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withLinearAnimation: MoveAnimation(moveToPosition: CGPoint(x: -3, y: 0)),
            duration: duration)
    }
    
    static func lookRight(duration: CFTimeInterval) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withLinearAnimation: MoveAnimation(moveToPosition: CGPoint(x: 3, y: 0)),
            duration: duration)
    }
    
    static func lookUp(duration: CFTimeInterval) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withLinearAnimation: MoveAnimation(moveToPosition: CGPoint(x: 0, y: -2)),
            duration: duration)
    }
    
    static func lookDown(duration: CFTimeInterval) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withLinearAnimation: MoveAnimation(moveToPosition: CGPoint(x: 0, y: 2)),
            duration: duration)
    }
    
    static func lookLeftCurve(duration: CFTimeInterval) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withCurveAnimation: MoveCurveAnimation(
                moveToQuadCurvePoint: CGPoint(x: -3, y: 0),
                moveToQuadCurveControlPoint: CGPoint(x: -1.5, y: 2)),
            duration: duration)
    }
    
    static func lookRightCurve(duration: CFTimeInterval) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withCurveAnimation: MoveCurveAnimation(
                moveToQuadCurvePoint: CGPoint(x: 3, y: 0),
                moveToQuadCurveControlPoint: CGPoint(x: 1.5, y: 2)),
            duration: duration)
    }
    
    static func finishedWriting1(duration: CFTimeInterval = 0.4) -> FaceAnimation {
        FaceAnimation(
            eyesAnimation: .linear(MoveAnimation(moveToPosition: CGPoint(x: 0, y: -8))),
            noseAnimation: .linear(MoveAnimation(moveToPosition: CGPoint(x: 0, y: -4))),
            mouthAnimation: .linear(MoveAnimation(moveToPosition: CGPoint(x: 0, y: -4))),
            backgroundAnimation: .linear(MoveAnimation(moveToPosition: CGPoint(x: 0, y: -2))),
            duration: duration)
    }
    
    static func writingLookLeft(duration: CFTimeInterval = 1.0) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withCurveAnimation: MoveCurveAnimation(
                moveToQuadCurvePoint: CGPoint(x: -2.0, y: 2.0),
                moveToQuadCurveControlPoint: CGPoint(x: -1.0, y: 2.5)),
            duration: duration)
    }
    
    static func writingLookRight(duration: CFTimeInterval = 1.0) -> FaceAnimation {
        FaceAnimation.fullFaceAnimation(
            withCurveAnimation: MoveCurveAnimation(
                moveToQuadCurvePoint: CGPoint(x: 2.0, y: 2.0),
                moveToQuadCurveControlPoint: CGPoint(x: 1.0, y: 2.5)),
            duration: duration)
    }
    
}

//struct SmileCenterFaceAnimation: FaceAnimation {
//    struct ZeroMoveAnimation: MoveAnimation {
//        var moveToPosition: CGPoint = CGPoint(x: 0, y: 0)
//    }
//    
//    var eyebrowsAnimation: FacialFeatureAnimationType? = .linear(ZeroMoveAnimation())
//    var eyesAnimation: FacialFeatureAnimationType? = .linear(ZeroMoveAnimation())
//    var noseAnimation: FacialFeatureAnimationType? = .linear(ZeroMoveAnimation())
//    var mouthAnimation: FacialFeatureAnimationType? = .linear(ZeroMoveAnimation())
//    var backgroundAnimation: FacialFeatureAnimationType? = .linear(ZeroMoveAnimation())
//    
//    var duration: CFTimeInterval
//    
//    init(duration: CFTimeInterval) {
//        self.duration = duration
//    }
//}
