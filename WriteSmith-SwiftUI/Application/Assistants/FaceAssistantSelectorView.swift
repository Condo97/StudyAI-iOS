//
//  FaceAssistantSelectorView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/28/24.
//

import CoreData
import FaceAnimation
import Foundation
import SwiftUI

struct FaceAssistantSelectorView: View {
    
    @Binding var useAssistant: Assistant?
    
    
    @Namespace var namespace
    
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)],
        predicate: NSPredicate(format: "%K = %d", #keyPath(Assistant.featured), true),
        animation: .default)
    private var faceAssistants: FetchedResults<Assistant>
    
    private static let faceDiameter: CGFloat = 86.0
    private static let faceFrame: CGRect = CGRect(x: 0, y: 0, width: faceDiameter, height: faceDiameter)
    private static let facialFeaturesScaleFactor: CGFloat = 0.76
    private static let faceColor: UIColor = UIColor(Colors.elementBackgroundColor)
    private static let faceStartAnimation: FaceAnimation = FaceAnimationRepository.center(duration: 0.0)
    private let circleInnerPadding: CGFloat = 0.0
    
    @State private var selectedAssistant: Assistant?
    
    @State private var isShowingUltraView: Bool = false
    
    
    var body: some View {
        ZStack {
            ScrollView {
                faceAssistantSelection
                    .padding([.leading, .trailing])
                
                if selectedAssistant?.assistantDescription != nil {
                    HStack {
                        Text("Description")
                            .font(.custom(Constants.FontName.heavy, size: 24.0))
                            .foregroundStyle(Colors.textOnBackgroundColor)
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing])
                    
                    description
                        .padding([.leading, .trailing])
                }
            }
        }
        .overlay {
            VStack {
                Spacer()
                
                Button(action: {
                    // Unwrap selectedAssistant, otherwise return
                    guard let selectedAssistant = selectedAssistant else {
                        // TODO: Handle errors
                        print("Error unwrapping selectedAssistant in FaceAssistantSelectorView!")
                        return
                    }
                    
                    // Ensure selectedAssistant is not premium or selectedAssistant is premium and user is too, otherwise show Ultra view and return
                    guard !selectedAssistant.premium || (selectedAssistant.premium && premiumUpdater.isPremium) else {
                        // Show Ultra View and return
                        isShowingUltraView = true
                        return
                    }
                    
                    // Set assistant as current assistant in CurrentAssistantPersistence
                    do {
                        try CurrentAssistantPersistence.setAssistant(selectedAssistant, in: viewContext)
                    } catch {
                        // TODO: Handle Errors
                        print("Error setting current assistant in FaceAssistantSelectorView... \(error)")
                    }
                    
                    // Set useAssistant as selectedAssistant
                    self.useAssistant = selectedAssistant
                }) {
                    ZStack {
                        HStack {
                            Text("Confirm")
                                .font(.custom(Constants.FontName.heavy, size: 20.0))
                        }
                        
                        HStack {
                            // Show lock if Assistant is premium and user is not
                            if let selectedAssistant = selectedAssistant, selectedAssistant.premium && !premiumUpdater.isPremium {
                                Text(Image(systemName: "lock"))
                                    .font(.custom(Constants.FontName.body, size: 20.0))
                            }
                            
                            Spacer()
                            
                            Text(Image(systemName: "chevron.right"))
                                .font(.custom(Constants.FontName.body, size: 20.0))
                        }
                    }
                }
                .disabled(selectedAssistant == nil)
                .foregroundStyle(Colors.elementTextColor)
                .opacity(selectedAssistant == nil ? 0.6 : 1.0)
                .padding()
                .background(Colors.elementBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding()
            }
        }
        .ultraViewPopover(isPresented: $isShowingUltraView)
        .toolbar {
            ToolbarItem(placement: .principal) {
                ZStack {
                    Text("Select an Assistant...")
                        .font(.custom(Constants.FontName.black, size: 24.0))
                        .foregroundStyle(Colors.navigationItemColor)
                }
            }
        }
        .onAppear {
            self.selectedAssistant = useAssistant
        }
    }
    
    var faceAssistantSelection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], content: {
            ForEach(faceAssistants) { assistant in
                if let name = assistant.name,
                   let eyesImageName = assistant.faceStyle?.eyesImageName,
                   let mouthImageName = assistant.faceStyle?.mouthImageName,
                   let noseImageName = assistant.faceStyle?.noseImageName,
                   let faceImageName = assistant.faceStyle?.backgroundImageName,
                   let eyesPositionFactor = assistant.faceStyle?.eyesPositionFactor,
                   let faceRenderingMode = assistant.faceStyle?.faceRenderingMode {
                    
                    let faceAnimationViewRepresentable = FaceAnimationResizableView(
//                        frame: FaceAssistantSelectorView.faceFrame,
                        eyesImageName: eyesImageName,
                        mouthImageName: mouthImageName,
                        noseImageName: noseImageName,
                        faceImageName: faceImageName,
                        facialFeaturesScaleFactor: FaceAssistantSelectorView.facialFeaturesScaleFactor,
                        eyesPositionFactor: eyesPositionFactor,
                        faceRenderingMode: faceRenderingMode,
                        color: FaceAssistantSelectorView.faceColor,
                        startAnimation: FaceAnimationRepository.center(duration: 0.0))
                    
                    Button(action: {
                        selectedAssistant = assistant
                    }) {
                        FaceAssistantView(
                            faceAnimationViewRepresentable: faceAnimationViewRepresentable,
                            circleInnerPadding: circleInnerPadding,
                            title: name,
                            subtitle: assistant.assistantShortDescription ?? assistant.category ?? "All Purpose",
                            premiumModel: assistant.premium)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundStyle(assistant == selectedAssistant ? Colors.elementTextColor : Colors.text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background(assistant == selectedAssistant ? Colors.elementBackgroundColor : Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
        })
    }
    
    var description: some View {
        ZStack {
            if let description = selectedAssistant?.assistantDescription {
                Text(description)
                    .font(.custom(Constants.FontName.body, size: 17.0))
            }
        }
        .padding()
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
}


//#Preview {
//    
//    NavigationStack {
//        FaceAssistantSelectorView(useAssistant: .constant(nil))
//            .background(Colors.background)
//    }
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//        .environmentObject(PremiumUpdater())
//        .environmentObject(ProductUpdater())
//    
//}
