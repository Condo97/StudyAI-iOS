//
//  FaceAssistantView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/25/24.
//

import FaceAnimation
import Foundation
import SwiftUI

struct FaceAssistantView: View {
    
    @State var faceAnimationViewRepresentable: FaceAnimationResizableView
    @State var circleInnerPadding: CGFloat
    @State var title: String
    @State var subtitle: String
    @State var premiumModel: Bool
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    
    var body: some View {
        VStack(spacing: 0.0) {
            ZStack {
                faceAnimationViewRepresentable
                    .background(Colors.elementTextColor)
                    .clipShape(Circle())
//                Circle()
//                    .fill(Colors.elementTextColor)
//                    .frame(width: faceAnimationViewRepresentable.frame.width + circleInnerPadding)
//                    .overlay(
//                        ZStack {
//                            faceAnimationViewRepresentable
//                                .frame(
//                                    width: faceAnimationViewRepresentable.frame.width,
//                                    height: faceAnimationViewRepresentable.frame.height)
//                        }
//                    )
            }
            .padding(.bottom, 8)
            
            HStack(spacing: 0.0) {
                Text(title)
                    .font(.custom(Constants.FontName.black, size: 17.0))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                if premiumModel && !premiumUpdater.isPremium {
                    Text(Image(systemName: "lock"))
                        .font(.custom(Constants.FontName.medium, size: 17.0))
                }
            }
            
            Text(subtitle)
                .font(.custom(Constants.FontName.body, size: 12.0))
                .multilineTextAlignment(.center)
//            if premiumModel {
//                HStack(spacing: 2.0) {
//                    Text(Image(systemName: "sparkles"))
//                    
//                    Text("GPT-4 + Vision")
//                }
//                .font(.custom(Constants.FontName.body, size: 10.0))
//                .lineLimit(1)
//                .minimumScaleFactor(0.5)
//                .foregroundStyle(Colors.elementTextColor)
//                .padding(2)
//                .padding([.leading, .trailing], 4)
//                .background(Colors.text)
//                .clipShape(RoundedRectangle(cornerRadius: 14.0))
//            } else {
//                Text("Free GPT-3.5 Turbo")
//                    .font(.custom(Constants.FontName.bodyOblique, size: 10.0))
//                    .foregroundStyle(Colors.text)
//                    .padding(2)
//                    .padding([.leading, .trailing], 2)
//            }
        }
    }
    
}

//#Preview {
//    
//    FaceAssistantView(
//        faceAnimationViewRepresentable:
//        FaceAnimationResizableView(
//            eyesImageName: "Man Eyes",
//            mouthImageName: "Man Mouth",
//            noseImageName: "Genius Nose",
//            faceImageName: "Genius Background",
//            facialFeaturesScaleFactor: 0.72,
//            eyesPositionFactor: 2.0/5.0,
//            faceRenderingMode: .alwaysTemplate,
//            color: UIColor(Colors.elementBackgroundColor),
//            startAnimation: FaceAnimationRepository.center(duration: 0.0)
//        ),
//        circleInnerPadding: 0.0,
//        title: "Genius",
//        subtitle: "Write, Study and Answer Questions",
//        premiumModel: true
//    )
//    .background(Colors.background)
//    .environmentObject(PremiumUpdater())
//    
//}
