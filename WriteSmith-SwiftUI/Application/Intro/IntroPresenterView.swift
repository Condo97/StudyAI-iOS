//
//  IntroPresenterView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import AVKit
import FirebaseAnalytics
import SwiftUI

struct IntroPresenterView: View {
    
    @Binding var isShowing: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let lightModeGenerateImageVideoName = "Image Generation Light"
    private let lightModeGenerateImageVideoExtension = "mp4"
    private let darkModeGenerateImageVideoName = "Image Generation Dark"
    private let darkModeGenerateImageVideoExtension = "mp4"
    
    private let lightModeScanImageVideoName = "Scan Images Light"
    private let lightModeScanImageVideoExtension = "mp4"
    private let darkModeScanImageVideoName = "Scan Images Dark"
    private let darkModeScanImageVideoExtension = "mp4"
    
    private let videoAspectRatio = 1284.0/2778.0
    
    
    var body: some View {
        let generateImageAVPlayer = AVPlayer(url: Bundle.main.url(
            forResource: colorScheme == .light ? lightModeGenerateImageVideoName : darkModeGenerateImageVideoName,
            withExtension: colorScheme == .light ? lightModeGenerateImageVideoExtension : darkModeGenerateImageVideoExtension)!)
        let scanImageAVPlayer = AVPlayer(url: Bundle.main.url(
            forResource: colorScheme == .light ? lightModeScanImageVideoName : darkModeScanImageVideoName,
            withExtension: colorScheme == .light ? lightModeScanImageVideoExtension : darkModeScanImageVideoExtension)!)
        
//        NavigationStack {
//            IntroVideoView(
//                avPlayer: generateImageAVPlayer,
//                videoAspectRatio: videoAspectRatio,
//                destination: {
//                    IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot2)!), destination: {
//                        IntroVideoView(
//                            avPlayer: scanImageAVPlayer,
//                            videoAspectRatio: videoAspectRatio,
//                            destination: {
//                                UltraView(isShowing: $isShowing)
//                                    .toolbar(.hidden, for: .navigationBar)
//                                    .onAppear {
//                                        IntroManager.isIntroComplete = true
//                                    }
//                            })
//                    })
//                })
//        }
        
        NavigationStack {
//            IntroAssistantSelectionView(isPresented: $isShowing)
//                .onAppear {
//                    // Log JustOneIntro_AssistantSelectionView
//                    Analytics.logEvent(AnalyticsEventScreenView,
//                                       parameters: [AnalyticsParameterScreenName: "JustOneIntro_AssistantSelectionView",
//                                                   AnalyticsParameterScreenClass: "JustOneIntro_AssistantSelectionView"])
//                }
//                .onChange(of: isShowing) { value in
//                    // Set introManager introComplete to true if isShowing is false since this indicates the user finished the intro lol
//                    if !value {
//                        IntroManager.isIntroComplete = true
//                    }
//                }
            IntroView(image: Image(uiImage: UIImage(named: Constants.ImageName.introScreenshot1)!), destination: {
//                IntroVideoView(
//                    avPlayer: generateImageAVPlayer,
//                    videoAspectRatio: videoAspectRatio,
//                    destination: {
                        IntroVideoView(
                            avPlayer: scanImageAVPlayer,
                            videoAspectRatio: videoAspectRatio,
                            destination: {
//                                IntroAssistantSelectionView {
                                    UltraView(isShowing: $isShowing)
                                        .toolbar(.hidden, for: .navigationBar)
                                        .onAppear {
                                            // Log fifth intro view
                                            Analytics.logEvent("intro_progression_v5.4", parameters: [
                                                "view": 5 as NSObject
                                            ])
                                            
                                            Analytics.logEvent(AnalyticsEventScreenView,
                                                               parameters: [AnalyticsParameterScreenName: "UltraViewFromIntro",
                                                                           AnalyticsParameterScreenClass: "UltraViewFromIntro"])
                                            
                                            IntroManager.isIntroComplete = true
                                        }
//                                }
//                                .onAppear {
//                                    // Log fourth intro view
//                                    Analytics.logEvent("intro_progression_v5.4", parameters: [
//                                        "view": 4 as NSObject
//                                    ])
//                                    
//                                    Analytics.logEvent(AnalyticsEventScreenView,
//                                                       parameters: [AnalyticsParameterScreenName: "IntroView4",
//                                                                   AnalyticsParameterScreenClass: "IntroView4"])
//                                }
                            })
                        .onAppear {
                            // Log third intro view
                            Analytics.logEvent("intro_progression_v5.4", parameters: [
                                "view": 3 as NSObject
                            ])
                            
                            Analytics.logEvent(AnalyticsEventScreenView,
                                               parameters: [AnalyticsParameterScreenName: "IntroView3",
                                                           AnalyticsParameterScreenClass: "IntroView3"])
                        }
                    })
//                .onAppear {
//                    // Log second intro view
//                    Analytics.logEvent("intro_progression_v5.4", parameters: [
//                        "view": 2 as NSObject
//                    ])
//                    
//                    Analytics.logEvent(AnalyticsEventScreenView,
//                                       parameters: [AnalyticsParameterScreenName: "IntroView2",
//                                                   AnalyticsParameterScreenClass: "IntroView2"])
//                }
//            })
            .onAppear {
                // Log first intro view
                Analytics.logEvent("intro_progression_v5.4", parameters: [
                    "view": 1 as NSObject
                ])
                
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "IntroView1",
                                               AnalyticsParameterScreenClass: "IntroView1"])
            }
        }
    }
    
}

//#Preview {
//    IntroPresenterView(isShowing: .constant(true))
//        .environmentObject(PremiumUpdater())
//        .environmentObject(ProductUpdater())
//}
