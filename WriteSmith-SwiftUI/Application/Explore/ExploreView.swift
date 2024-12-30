//
//  ExploreView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct ExploreView: View {
    
    @State var panelGroups: [PanelGroup]
    
    @EnvironmentObject var premiumUpdater: PremiumUpdater
    @EnvironmentObject var productUpdater: ProductUpdater
    @EnvironmentObject var remainingUpdater: RemainingUpdater
    
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Namespace private var namespace
    
    @State private var selectedSection: String = allSectionFilter
    
    @State private var presentingPanel: Panel?
    
//    @State private var isShowingSettingsView: Bool = false
    
    private let panelSize = CGSize(width: 170.0, height: 120.0)
    private let selectedSectionUnderlineMatchedGeometryEffectID = "selectedSectionUnderline"
    private static let allSectionFilter = "All"
    private let allSectionFilter = ExploreView.allSectionFilter
    
    private var sections: [String] {
        [allSectionFilter] + panelGroups.map({$0.name})
    }
    
    private var isShowingPresentingPanelView: Binding<Bool> {
        Binding(
            get: {
                presentingPanel != nil
            },
            set: { newValue in
                if !newValue {
                    presentingPanel = nil
                }
            })
    }
    
    init(panelGroups: [PanelGroup]) {
        self._panelGroups = State(initialValue: panelGroups)
        
        // Configure navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
//                if !premiumUpdater.isPremium {
//                    BannerView(bannerID: Keys.Ads.Banner.exploreView)
//                }
                
                filterDisplay
                    .padding(.top, 8)
                
                if selectedSection == allSectionFilter {
                    sectionedPanelsDisplay
                } else {
                    filteredPanelsDisplay
                }
            }
        }
//        .overlay {
//            VStack {
//                Image(Constants.ImageName.blurryNavBarBackground)
//                    .resizable()
//                    .frame(height: 160.0)
//                    .foregroundStyle(Colors.background)
//                
//                Spacer()
//            }
//            .ignoresSafeArea()
//            .allowsHitTesting(false)
//        }
        .background(Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
//            SettingsToolbarItem(
//                elementColor: .constant(Colors.navigationItemColor),
//                placement: .topBarLeading,
//                tightenLeadingSpacing: true,
//                tightenTrailingSpacing: true,
//                action: {
//                isShowingSettingsView = true
//            })
            
            ShareToolbarItem(
                elementColor: .constant(Colors.navigationItemColor),
                placement: .topBarLeading,
                tightenLeadingSpacing: true)
            
            ToolbarItem(placement: .principal) {
                ZStack {
                    Text("Explore")
                        .font(.custom(Constants.FontName.black, size: 24.0))
                        .foregroundStyle(Colors.navigationItemColor)
                }
            }
            
            if !premiumUpdater.isPremium {
                UltraToolbarItem()
            }
        }
//        .navigationDestination(isPresented: $isShowingSettingsView, destination: {
//            SettingsView()
//        })
        .navigationDestination(isPresented: isShowingPresentingPanelView, destination: {
            if let presentingPanel = presentingPanel {
                ExplorePanelView(panel: presentingPanel)
            }
        })
    }
    
    var filterDisplay: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(sections, id: \.self) { section in
                    ZStack {
                        KeyboardDismissingButton(action: {
                            // Do light haptic
                            HapticHelper.doLightHaptic()
                            
                            withAnimation {
                                // Set selected section to section
                                selectedSection = section
                            }
                        }) {
                            Text(section)
                                .font(.custom(selectedSection == section ? Constants.FontName.heavy : Constants.FontName.body, size: 17.0))
                                .animation(.easeInOut(duration: 0.0))
                        }
                        .foregroundStyle(selectedSection == section ? Colors.elementTextColor : (colorScheme == .dark ? Colors.elementBackgroundColor : Colors.textOnBackgroundColor))
                    }
                    .padding([.top, .bottom], 8)
                    .padding([.leading, .trailing], 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14.0)
                            .fill(selectedSection == section ? Colors.elementBackgroundColor : Colors.elementTextColor)
//                            .matchedGeometryEffect(id: selectedSectionUnderlineMatchedGeometryEffectID, in: namespace)
//                        VStack {
//                            Spacer()
//                            
//                            if selectedSection == section {
//                                Rectangle()
//                                    .frame(height: 2.0)
//                                    .matchedGeometryEffect(id: selectedSectionUnderlineMatchedGeometryEffectID, in: namespace)
//                            }
//                        }
                    )
                }
            }
            .padding([.leading, .trailing])
        }
        .scrollIndicators(.hidden)
    }
    
    var sectionedPanelsDisplay: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8.0) {
                ForEach(panelGroups) { panelGroup in
                    Text(panelGroup.name)
                        .font(.custom(Constants.FontName.black, size: 24.0))
                        .padding(.top, 8)
                        .padding([.leading, .trailing])
                        .foregroundStyle(Colors.textOnBackgroundColor)
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(panelGroup.panels) { panel in
                                KeyboardDismissingButton(action: {
                                    // Do light haptic
                                    HapticHelper.doLightHaptic()
                                    
                                    // Set presentingPanel to panel
                                    presentingPanel = panel
                                }) {
                                    PanelMiniView(panel: panel)
                                }
                                .foregroundStyle(Colors.text)
                                .frame(width: panelSize.width, height: panelSize.height)
//                                .bounceable()
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                    .scrollIndicators(.never)
                }
            }
            
            Spacer(minLength: 140.0)
        }
        .scrollIndicators(.never)
    }
    
    var filteredPanelsDisplay: some View {
        ScrollView(.vertical) {
            if let selectedPanelGroup = panelGroups.first(where: {$0.name == selectedSection}) {
                LazyVStack(alignment: .leading) {
                    Text(selectedPanelGroup.name)
                        .font(.custom(Constants.FontName.black, size: 24.0))
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8.0) {
                        ForEach(selectedPanelGroup.panels) { panel in
                            KeyboardDismissingButton(action: {
                                // Do light haptic
                                HapticHelper.doLightHaptic()
                                
                                // Set presentingPanel to panel
                                presentingPanel = panel
                            }) {
                                PanelMiniView(panel: panel)
                            }
                            .foregroundStyle(Colors.text)
                            .frame(width: panelSize.width, height: panelSize.height)
                            .bounceable()
                        }
                    }
                }
                .padding()
            }
            
            Spacer(minLength: 140.0)
        }
    }
    
}

//#Preview {
//    NavigationStack {
//        ExploreView(panelGroups: try! PanelParser.parsePanelGroups(fromJson: PanelPersistenceManager.get()!)!)
//    }
//    .environmentObject(RemainingUpdater())
//    .environmentObject(PremiumUpdater())
//    .environmentObject(ProductUpdater())
//}
