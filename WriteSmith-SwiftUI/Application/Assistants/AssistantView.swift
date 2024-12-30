//
//  AssistantView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/24/24.
//

import FaceAnimation
import SwiftUI

struct AssistantView: View {
    
    var assistant: Assistant
    var diameter: CGFloat = 76.0
    
    var body: some View {
        // Face/Image/Emoji on Left
        if let faceStyle = assistant.faceStyle {
            FaceAnimationResizableView(
//                frame: CGRect(x: 0, y: 0, width: diameter, height: diameter),
                eyesImageName: faceStyle.eyesImageName,
                mouthImageName: faceStyle.mouthImageName,
                noseImageName: faceStyle.noseImageName,
                faceImageName: faceStyle.backgroundImageName,
                facialFeaturesScaleFactor: 0.72,
                eyesPositionFactor: faceStyle.eyesPositionFactor,
                faceRenderingMode: faceStyle.faceRenderingMode,
                color: UIColor(Colors.navigationItemColor),
                startAnimation: FaceAnimationRepository.center(duration: 0.0),
                idleAnimations: RandomFaceIdleAnimationSequence.smile.animationSequence.animations)
            .aspectRatio(contentMode: .fit)
//                .padding(.bottom, -2)
            //                                    .padding(.trailing, -8)
            //                                    .padding([.top, .bottom], -8)
        } else if let uiImage = assistant.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .frame(height: diameter)
//                .padding(.trailing)
        } else if let emoji = assistant.emoji {
            Text(emoji)
                .font(.custom(Constants.FontName.body, size: 28.0))
//                .padding(8)
//                .padding([.leading, .trailing], 8)
                .padding(.horizontal)
        }
    }
    
}

//#Preview {
//    
//    let assistant = try! CDClient.mainManagedObjectContext.fetch(Assistant.fetchRequest())[0]
//    
//    return AssistantView(assistant: assistant)
//    
//}
