//
//  AssistantsView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/25/24.
//

import FaceAnimation
import Foundation
import SwiftUI
import UIKit

struct AssistantsView: View {
    
    @Binding var isPresented: Bool
    @Binding var faceAssistant: Assistant?
    @Binding var selectedAssistant: Assistant?
    
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)],
//        predicate: NSPredicate(format: "(%K = %@ or %K = %@ or %K = %@) and %K != nil", #keyPath(Assistant.category), AssistantCategories.celebrity.rawValue, #keyPath(Assistant.category), AssistantCategories.character.rawValue, #keyPath(Assistant.category), AssistantCategories.roleplay.rawValue, #keyPath(Assistant.imagePath)),
//        animation: .default)
//    private var featuredAssistants: FetchedResults<Assistant>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)],
        predicate: NSPredicate(format: "%K = %d", #keyPath(Assistant.userCreated), true),
        animation: .default)
    private var userCreatedAssistants: FetchedResults<Assistant>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)],
        predicate: NSPredicate(format: "%K = %d and %K = %d", #keyPath(Assistant.featured), false, #keyPath(Assistant.userCreated), false),
        animation: .default)
    private var otherAssistants: FetchedResults<Assistant>
    
    @State private var presentingAssistant: Assistant?
    var isPresentingAssistant: Binding<Bool> {
        Binding(
            get: {
                presentingAssistant != nil
            },
            set: { value in
                if !value {
                    presentingAssistant = nil
                }
            })
    }
    @State private var presentingAssistantConfirmedForUse: Bool = false
    
    @State private var isDisplayingSearchable: Bool = false
    
//    @State private var isShowingFaceAssistantSelectorView: Bool = false
    @State private var isShowingSettingsView: Bool = false
    @State private var isShowingUltraView: Bool = false
    
    @State private var searchText: String = ""
    @State private var selectedSortItem: AssistantCategories?
    var isPresentingSortItem: Binding<Bool> {
        Binding(
            get: {
                selectedSortItem != nil
            },
            set: { value in
                if !value {
                    selectedSortItem = nil
                }
            })
    }
    
    private static let faceDiameter: CGFloat = 86.0
    private static let faceFrame: CGRect = CGRect(x: 0, y: 0, width: faceDiameter, height: faceDiameter)
    private static let facialFeaturesScaleFactor: CGFloat = 0.76
    private static let faceStartAnimation: FaceAnimation = FaceAnimationRepository.center(duration: 0.0)
    private let circleInnerPadding: CGFloat = 0.0
    
    private let assistantSortItems: [AssistantCategories] = AssistantSortModel.sortItems.compactMap({$0 == .general || $0 == .other ? nil : $0})
    
    
//    @State private var originalFAVR: FaceAnimationViewRepresentable = FaceAnimationViewRepresentable(
//        frame: CGRect(x: 0, y: 0, width: faceDiameter, height: faceDiameter),
//        showsMouth: false,
//        noseImageName: "Genius Nose",
//        faceImageName: "Genius Background",
//        facialFeaturesScaleFactor: 0.72,
//        color: UIColor(Colors.elementBackgroundColor),
//        startAnimation: SmileCenterFaceAnimation(duration: 0.0))
//    
//    @State private var artistFAVR: FaceAnimationViewRepresentable = FaceAnimationViewRepresentable(
//        frame: CGRect(x: 0, y: 0, width: faceDiameter, height: faceDiameter),
//        showsMouth: true,
//        noseImageName: "Artist Nose",
//        faceImageName: "Artist Background",
//        facialFeaturesScaleFactor: 0.72,
//        color: UIColor(Colors.elementBackgroundColor),
//        startAnimation: SmileCenterFaceAnimation(duration: 0.0))
//    
//    @State private var geniusFAVR: FaceAnimationViewRepresentable = FaceAnimationViewRepresentable(
//        frame: CGRect(x: 0, y: 0, width: faceDiameter, height: faceDiameter),
//        showsMouth: false,
//        noseImageName: "Genius Nose",
//        faceImageName: "Genius Background",
//        facialFeaturesScaleFactor: 0.72,
//        color: UIColor(Colors.elementBackgroundColor),
//        startAnimation: SmileCenterFaceAnimation(duration: 0.0))
    
    init(isPresented: Binding<Bool>, faceAssistant: Binding<Assistant?>, selectedAssistant: Binding<Assistant?>) {
        self._isPresented = isPresented
        self._faceAssistant = faceAssistant
        self._selectedAssistant = selectedAssistant
        
//        // Configure navigation bar
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithTransparentBackground()
//        appearance.backgroundColor = .clear
//        
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                if searchText.isEmpty {
                    ScrollView {
                        VStack(spacing: 0.0) {
                            // Search Bar
                            //                    searchBar
                            
                            // Active Assistant
                            activeAssistant
                                .padding([.top, .bottom], 8)
                                .padding([.leading, .trailing])
                            
                            Spacer()
                            
                            HStack {
                                Text("All Assistants")
                                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                                    .padding(.top, 2)
                                    .foregroundStyle(Colors.textOnBackgroundColor)
                                
                                Spacer()
                            }
                            .padding([.leading, .trailing])
                            .padding(.bottom)
                            
                            // Sorting Assistants
                            assistantSorting
                            
//                            // Featured Assistants
//                            featured
                            
                            // User Created Assistants
                            if userCreatedAssistants.count > 0 {
                                Text("My Assistants")
                                    .font(.custom(Constants.FontName.black, size: 24.0))
                                    .padding(.bottom, 2)
                                    .foregroundStyle(Colors.textOnBackgroundColor)
                                userCreated
                                    .padding(8)
                                    .padding([.leading, .trailing], 8)
                                    .background(Colors.foreground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                    .padding()
                            }
                            
                            Spacer()
                            
                            // Other Assistants
                            HStack {
                                Text("Trending")
                                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                                    .padding(.top, 2)
                                    .foregroundStyle(Colors.textOnBackgroundColor)
                                
                                Spacer()
                            }
                            .padding([.leading, .trailing])
                            .padding(.bottom)
                            
                            other
                                .padding(8)
                                .padding([.leading, .trailing], 8)
                                .background(Colors.foreground)
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                .padding([.leading, .trailing])
                                .padding(.bottom)
                            
                            Spacer(minLength: 150.0)
                        }
                    }
                    .background(Colors.background)
                } else {
                    List {
                        filteredResults
                    }
                    .background(Colors.background)
                }
            }
            .searchable(text: $searchText)
//            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Colors.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ZStack {
                        Button(action: {
                            self.isPresented = false
                        }) {
                            Text("Close")
                        }
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                        .foregroundStyle(Colors.navigationItemColor)
                    }
                }
                
                ShareToolbarItem(
                    elementColor: .constant(Colors.navigationItemColor),
                    placement: .topBarTrailing,
                    tightenTrailingSpacing: true)
                
                ToolbarItem(placement: .principal) {
                    ZStack {
                        Text("Assistants")
                            .font(.custom(Constants.FontName.black, size: 24.0))
                            .foregroundStyle(Colors.navigationItemColor)
                    }
                }
                
                if !premiumUpdater.isPremium {
                    UltraToolbarItem()
                }
            }
            .onChange(of: presentingAssistantConfirmedForUse) { newValue in
                // Set presentingAssistantConfirmedForUse to false to allow for selection again
                presentingAssistantConfirmedForUse = false
                
                // Ensure presentingAssistant is not premium or is premium and user is premium, otherwise show ultra view and return
                guard let presentingAssistant = presentingAssistant, !presentingAssistant.premium || presentingAssistant.premium && premiumUpdater.isPremium else {
                    isShowingUltraView = true
                    return
                }
                
                // Set SelectedAssistant
                self.selectedAssistant = presentingAssistant
                
//                if let presentingAssistant = presentingAssistant {
//                    // Set assistant in activeAssistantUpdater as presentingAssistant
//                    do {
//                        try activeAssistantUpdater.setAssistant(presentingAssistant, in: viewContext)
//                    } catch {
//                        print("Error setting active assistant in AssistantsView... \(error)")
//                    }
//                }
                
//                // Set presentingAssistant to nil and presentingAssistantConfirmedForUse to false
//                presentingAssistant = nil
//                presentingAssistantConfirmedForUse = false
            }
            .ultraViewPopover(isPresented: $isShowingUltraView)
//            .navigationDestination(isPresented: $isShowingFaceAssistantSelectorView) {
//                FaceAssistantSelectorView(useAssistant: $faceAssistant)
//                    .background(Colors.background)
//            }
            .navigationDestination(isPresented: $isShowingSettingsView) {
                SettingsView()
            }
            .navigationDestination(isPresented: isPresentingAssistant) {
                if presentingAssistant != nil {
                    AssistantDetailView(
                        assistant: presentingAssistant.unsafelyUnwrapped,
                        setAssistantConfirmed: $presentingAssistantConfirmedForUse)
                }
            }
            .navigationDestination(isPresented: isPresentingSortItem) {
                if let selectedSortItem = selectedSortItem {
                    AssistantsSortSpecFilteredView(
                        assistantCategory: selectedSortItem,
                        selectedAssistant: $selectedAssistant)
                    .padding()
                    .background(Colors.background)
                }
            }
//            .onChange(of: faceAssistant) { newValue in
//                // If faceAssistant is changed and isShowingFaceAssistantSelectorView is true set isShowingFaceAssistantSelectorView to false and selectedAssistant to faceAssistant to dismiss, save, and create a new chat since the user seemingly confirmed a new faceAssistant for use :)
//                if isShowingFaceAssistantSelectorView {
//                    self.isShowingFaceAssistantSelectorView = false
//                    
//                    self.selectedAssistant = faceAssistant
//                }
//            }
            
        }
        
    }
    
//    var searchBar: some View {
//        
//    }
    
    var activeAssistant: some View {
        ZStack {
            Button(action: {
                // Set selectedAssistant to faceAssistant, which will create a new chat with ConversationCreationAssistantsView
                self.selectedAssistant = faceAssistant
            }) {
                ZStack {
                    HStack {
                        if let eyesImageName = faceAssistant?.faceStyle?.eyesImageName,
                           let mouthImageName = faceAssistant?.faceStyle?.mouthImageName,
                           let noseImageName = faceAssistant?.faceStyle?.noseImageName,
                           let faceImageName = faceAssistant?.faceStyle?.backgroundImageName,
                           let eyesPositionFactor = faceAssistant?.faceStyle?.eyesPositionFactor,
                           let faceRenderingMode = faceAssistant?.faceStyle?.faceRenderingMode {
                            
                            FaceAnimationResizableView(
//                                frame: AssistantsView.faceFrame,
                                eyesImageName: eyesImageName,
                                mouthImageName: mouthImageName,
                                noseImageName: noseImageName,
                                faceImageName: faceImageName,
                                facialFeaturesScaleFactor: AssistantsView.facialFeaturesScaleFactor,
                                eyesPositionFactor: eyesPositionFactor,
                                faceRenderingMode: faceRenderingMode,
                                color: UIColor(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor),
                                startAnimation: FaceAnimationRepository.center(duration: 0.0))
                            .frame(width: AssistantsView.faceDiameter, height: AssistantsView.faceDiameter)
                            .offset(y: 1)
                            .padding(.leading)
                        } else {
                            FaceAnimationResizableView(
//                                frame: AssistantsView.faceFrame,
                                eyesImageName: FaceStyles.worm.eyesImageName,
                                mouthImageName: FaceStyles.worm.mouthImageName,
                                noseImageName: FaceStyles.worm.noseImageName,
                                faceImageName: FaceStyles.worm.backgroundImageName,
                                facialFeaturesScaleFactor: AssistantsView.facialFeaturesScaleFactor,
                                eyesPositionFactor: FaceStyles.worm.eyesPositionFactor,
                                faceRenderingMode: FaceStyles.worm.faceRenderingMode,
                                color: UIColor(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor),
                                startAnimation: FaceAnimationRepository.center(duration: 0.0))
                            .frame(width: AssistantsView.faceDiameter, height: AssistantsView.faceDiameter)
                            .offset(y: 1)
                            .padding(.leading)
                        }
                        
                        VStack(alignment: .leading, spacing: 0.0) {
//                            Text("My AI")
//                                .font(.custom(Constants.FontName.blackOblique, size: 14.0))
//                                .foregroundStyle(Colors.text)
//                                .padding(.top)
                            
//                            if let name = faceAssistant.name {
//                                Text(name)
//                                    .font(.custom(Constants.FontName.body, size: 24.0))
//                                    .foregroundStyle(Colors.text)
//                            } else {
//                                Text("No Name")
//                                    .font(.custom(Constants.FontName.body, size: 24.0))
//                                    .foregroundStyle(Colors.text)
//                            }
                            
                            Text("Study AI")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                                .foregroundStyle(Colors.text)
                            
                            Text("Tap to Start Chatting")
                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                                .foregroundStyle(Colors.text)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .imageScale(.large)
                            .foregroundStyle(Colors.text)
                            .padding()
                    }
                    
//                        VStack {
//                            Spacer()
//
//                            Text("New Ask Anything Chat...")
//                                .font(.custom(Constants.FontName.lightOblique, size: 14.0))
//                                .padding(.bottom, 8)
//                                .foregroundStyle(Colors.text)
//                        }
                    
//                        VStack {
//                            HStack {
//                                Spacer()
//
//                                Button(action: {
//                                    // Show face assistant selector view
//                                    self.isShowingFaceAssistantSelectorView = true
//                                }) {
//                                    Text(Image(systemName: "repeat"))
//                                        .padding()
//                                        .foregroundStyle(Colors.text)
//                                }
//                            }
//
//                            Spacer()
//                        }
                }
            }
        }
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .bounceable()
    }
    
    var assistantSorting: some View {
        AssistantsCategoryListView(selectedSortItem: $selectedSortItem)
    }
    
//    var featured: some View {
//        ScrollView(.horizontal) {
//            LazyHStack {
//                ForEach(featuredAssistants) { assistant in
//                    Button(action: {
//                        self.presentingAssistant = assistant
//                    }) {
//                        VStack {
//                            ZStack {
//                                if let uiImage = assistant.uiImage {
//                                    Image(uiImage: uiImage)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                } else if let emoji = assistant.emoji {
//                                    Text(emoji)
//                                }
//                            }
//                            
//                            if let name = assistant.name {
//                                HStack {
//                                    Text(name)
//                                        .font(.custom(Constants.FontName.body, size: 17.0))
//                                        .lineLimit(1)
//                                        .minimumScaleFactor(0.5)
//                                        .foregroundStyle(Colors.text)
//                                    
//                                    Spacer()
//                                }
//                                .padding([.leading, .trailing])
//                            }
//                            
//                            if let category = assistant.category {
//                                HStack {
//                                    Text(category)
//                                        .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
//                                        .foregroundStyle(Colors.text)
//                                        .opacity(0.6)
//                                    
//                                    Spacer()
//                                }
//                                .padding([.leading, .trailing])
//                            }
//                        }
//                        .padding(.bottom)
//                        .frame(width: 160)
//                        .background(Color.foreground)
//                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
////                        .padding()
//                    }
////                    .bounceable()
//                }
//            }
//            .padding()
//        }
//        .scrollIndicators(.never)
//    }
    
    var userCreated: some View {
        VStack {
            LazyVStack {
                ForEach(userCreatedAssistants) { assistant in
                    
                }
            }
        }
    }
    
    var filteredResults: some View {
        ForEach(otherAssistants.filter({
            ($0.name != nil && $0.name!.contains(searchText)) || ($0.category != nil && $0.category!.contains(searchText))
        })) { assistant in
            // TODO: This is copied from otherAssistants.. Move this somewhere more reusable!
            Button(action: {
                self.presentingAssistant = assistant
            }) {
                VStack {
                    HStack(spacing: 16.0) {
                        let emojiBackgroundColor: Color? = {
                            if let displayBackgroundColorName = assistant.displayBackgroundColorName,
                               let uiColor = UIColor(named: displayBackgroundColorName) {
                                return Color(uiColor)
                            }
                            
                            return nil
                        }()
                        
                        ZStack {
                            if let uiImage = assistant.uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else if let emoji = assistant.emoji {
                                Text(emoji)
                                    .font(.custom(Constants.FontName.body, size: 28.0))
                                    .padding(4)
                            }
                        }
                        .frame(width: 40.0, height: 40.0)
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
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        
                        VStack(alignment: .leading) {
                            if let name = assistant.name {
                                Text(name)
                                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            if let category = assistant.category {
                                Text(category)
                                    .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                                    .opacity(0.6)
                            }
                        }
                        
                        Spacer()
                        
                        Text(Image(systemName: "chevron.right"))
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            .opacity(0.6)
                    }
                    .foregroundStyle(Colors.text)
                    .padding([.top, .bottom], 8)
                }
            }
        }
        
    }
    
    var other: some View {
        VStack {
            ForEach(otherAssistants) { assistant in
                Button(action: {
                    self.presentingAssistant = assistant
                }) {
                    VStack {
                        HStack(spacing: 16.0) {
                            let emojiBackgroundColor: Color? = {
                                if let displayBackgroundColorName = assistant.displayBackgroundColorName,
                                   let uiColor = UIColor(named: displayBackgroundColorName) {
                                    return Color(uiColor)
                                }
                                
                                return nil
                            }()
                            
                            ZStack {
                                if let uiImage = assistant.uiImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else if let emoji = assistant.emoji {
                                    Text(emoji)
                                        .font(.custom(Constants.FontName.body, size: 28.0))
                                        .padding(4)
                                }
                            }
                            .frame(width: 40.0, height: 40.0)
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
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                            
                            VStack(alignment: .leading) {
                                if let name = assistant.name {
                                    Text(name)
                                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                                        .multilineTextAlignment(.leading)
                                }
                                
                                if let category = assistant.category {
                                    Text(category)
                                        .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                                        .opacity(0.6)
                                }
                            }
                            
                            Spacer()
                            
                            Text(Image(systemName: "chevron.right"))
                                .font(.custom(Constants.FontName.body, size: 14.0))
                                .opacity(0.6)
                        }
                        .foregroundStyle(Colors.text)
                        .padding([.top, .bottom], 8)
                    }
                }
            }
        }
    }
    
}


//#Preview {
//    
//    ZStack {
//        AssistantsView(
//            isPresented: .constant(true),
//            faceAssistant: .constant(try? CurrentAssistantPersistence.getAssistant(in: CDClient.mainManagedObjectContext)),
//            selectedAssistant: .constant(nil))
//    }
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    .environmentObject(PremiumUpdater())
//    .environmentObject(ProductUpdater())
//    .environmentObject(RemainingUpdater())
//    .task {
//        Task(priority: .high) {
//            do {
//                try await DefaultAssistantsCoreDataLoader.deleteDeviceCreatedAssistantsInCoreData(in: CDClient.mainManagedObjectContext)
//                
//                // TODO: Version handling
//                if try await !DefaultAssistantsCoreDataLoader.deviceCreatedAssistantExists(in: CDClient.mainManagedObjectContext) {
//                    try await DefaultAssistantsCoreDataLoader.loadDefaultAssistantsInCoreData(in: CDClient.mainManagedObjectContext)
//                }
//            } catch {
//                // TODO: Handle Errors
//                print("Error loading or checking default assistants in CoreData... \(error)")
//            }
//        }
//    }
//    
//}
