//
//  AssistantDetailView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/26/24.
//

import FaceAnimation
import Foundation
import SwiftUI

struct AssistantDetailView: View {
    
    @State var assistant: Assistant
    @Binding var setAssistantConfirmed: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    private let faceFrameDiameter: CGFloat = 128.0
    
    
    var body: some View {
        ScrollView {
            VStack {
                // Face/Image/Emoji
                HStack {
                    Spacer()
                    
                    let emojiBackgroundColor: Color? = {
                        if let displayBackgroundColorName = assistant.displayBackgroundColorName,
                           let uiColor = UIColor(named: displayBackgroundColorName) {
                            return Color(uiColor)
                        }
                        
                        return nil
                    }()
                    
                    ZStack {
                        if let faceStyle = assistant.faceStyle {
                            FaceAnimationViewRepresentable(
                                frame: CGRect(x: 0, y: 0, width: faceFrameDiameter, height: faceFrameDiameter),
                                eyesImageName: faceStyle.eyesImageName,
                                mouthImageName: faceStyle.mouthImageName,
                                noseImageName: faceStyle.noseImageName,
                                faceImageName: faceStyle.backgroundImageName,
                                facialFeaturesScaleFactor: 0.72,
                                eyesPositionFactor: faceStyle.eyesPositionFactor,
                                faceRenderingMode: faceStyle.faceRenderingMode,
                                color: UIColor(Colors.elementBackgroundColor),
                                startAnimation: FaceAnimationRepository.center(duration: 0.0))
                            .frame(width: faceFrameDiameter, height: faceFrameDiameter)
                            .padding(4)
                        } else if let uiImage = assistant.uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                        } else if let emoji = assistant.emoji {
                            Text(emoji)
                                .font(.custom(Constants.FontName.body, size: 80.0))
                                .padding(4)
                        }
                    }
                    .frame(width: 160.0, height: 160.0)
                    .aspectRatio(contentMode: .fill)
                    .background(
                        ZStack {
                            Colors.background
                            
                            ZStack {
                                emojiBackgroundColor ?? Colors.foreground
                            }
                            .opacity(0.6)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                    Spacer()
                }
                
                // Name
                ZStack {
                    if let name = assistant.name {
                        Text(name)
                            .font(.custom(Constants.FontName.black, size: 28.0))
                            .multilineTextAlignment(.center)
                    }
                }
                .foregroundStyle(Colors.textOnBackgroundColor)
                
//                if let usageMessages = assistant.usageMessages, let usageUsers = assistant.usageUsers {
//                    HStack {
//                        Spacer()
//                        Text("Messages: \(usageMessages.)")
//
//                        
//                        Spacer()
//                    }
//                }
                
                // Description
                ZStack {
                    if let description = assistant.assistantDescription {
                        Text(description)
                            .font(.custom(Constants.FontName.body, size: 17.0))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding([.leading, .trailing])
                
                // Prompt - Does not show if assistant is featured
                VStack {
                    if let prompt = assistant.systemPrompt, !assistant.featured {
                        HStack {
                            Text("Prompt")
                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                                .foregroundStyle(Colors.textOnBackgroundColor)
                            
                            Spacer()
                        }
                        .padding(.leading)
                        
                        ZStack {
                            Text(prompt)
                                .font(.custom(Constants.FontName.body, size: 14.0))
                                .foregroundStyle(Colors.text)
                        }
                        .padding()
                        .background(Colors.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    }
                }
                .padding()
                
                // Bottom padding for button
                VStack {
                    
                }
                .frame(height: 150.0)
            }
        }
        .background(Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                ZStack {
                    Text("Assistant")
                        .font(.custom(Constants.FontName.black, size: 24.0))
                        .foregroundStyle(Colors.navigationItemColor)
                }
            }
        }
        .overlay {
            VStack {
                Spacer()
                
                ZStack {
                    Button(action: {
                        setAssistantConfirmed = true
                    }) {
                        ZStack {
                            HStack {
                                Spacer()
                                
                                
                                Text("Set Assistant")
                                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                                    .foregroundStyle(Colors.elementTextColor)
                                
                                Spacer()
                            }
                            
                            if assistant.premium && !premiumUpdater.isPremium {
                                HStack {
                                    Text(Image(systemName: "lock"))
                                        .font(.custom(Constants.FontName.body, size: 20.0))
                                        .foregroundStyle(Colors.elementTextColor)
                                    
                                    Spacer()
                                }
                            }
                            
                            HStack {
                                Spacer()
                                
                                Text(Image(systemName: "chevron.right"))
                                    .font(.custom(Constants.FontName.body, size: 20.0))
                                    .foregroundStyle(Colors.elementTextColor)
                            }
                        }
                    }
                }
                .padding()
                .background(Colors.elementBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding()
                .padding(.bottom, 28)
            }
        }
    }
    
}


//@available(iOS 17.0, *)
//#Preview {
//    
//    var results: [Assistant]?
//    CDClient.mainManagedObjectContext.performAndWait {
//        let fetchRequest = Assistant.fetchRequest()
//        
//        results = try? CDClient.mainManagedObjectContext.fetch(fetchRequest)
//    }
//    
//    return AssistantDetailView(
//        assistant: results![0],
//        setAssistantConfirmed: .constant(true)
//    )
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
