//
//  ExplorePanelView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import CoreData
import SwiftUI

struct ExplorePanelView: View {
    
    @State var panel: Panel
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @StateObject private var simpleChatGenerator: SimpleChatGenerator = SimpleChatGenerator()
    
    @State private var isShowingExploreChatsDisplayView: Bool = false
    @State private var isShowingInterstitial: Bool = false
    
    var body: some View {
        PanelView(
            panel: $panel,
            isLoading: $simpleChatGenerator.isLoading,
            buttonText: "Generate...",
            onGenerate: { finalizedPrompt in
                // Show interstitial if not premium
                if !premiumUpdater.isPremium {
                    isShowingInterstitial = true
                }
                
                // Generate
                Task {
                    // Set isShowingExploreChatsDisplayView to true
                    await MainActor.run {
                        isShowingExploreChatsDisplayView = true
                    }
                    
                    // Ensure authToken
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle errors
                        print("Error ensureing AuthToken in EssayActionCollectionFlowView... \(error)")
                        return
                    }
                    
                    // Stream chat
                    do {
                        try await simpleChatGenerator.generate(
                            input: finalizedPrompt,
                            image: nil,
                            imageURL: nil,
                            isPremium: premiumUpdater.isPremium)
                    } catch {
                        // TODO: Handle Errors
                        print("Error streaming chat in ExplorePanelView... \(error)")
                        return
                    }
                }
            })
        .background(
            InterstitialView(interstitialID: Keys.Ads.Interstitial.panelView, disabled: $premiumUpdater.isPremium, isPresented: $isShowingInterstitial))
        .navigationDestination(isPresented: $isShowingExploreChatsDisplayView, destination: {
            ExploreChatsDisplayContainer(
                simpleChatGenerator: simpleChatGenerator)
        })
    }
    
}

//#Preview {
//    
//    ExplorePanelView(
//        panel: PanelGroupSpec.panelGroups.first!.panels.first!)
//    
//}
//
