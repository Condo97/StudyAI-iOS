//
//  EssayOutlineActionView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/21/24.
//

import SwiftUI

struct EssayOutlineActionView: View, ActionViewProtocol {
    
    @State var action: Action
    @State var buttonText: String
    var onGenerate: (String) async -> Void
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @State private var isButtonLoadingAndDisabled: Bool = false
    
    private var allDrawersHeaderTitlesForRegenerationForChatWithDrawerCollection: String? {
        guard let drawerCollection = action.drawerCollection else {
            return nil
        }
        
        let fetchRequest = GeneratedDrawer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(GeneratedDrawer.parentCollection), drawerCollection)
        
        return viewContext.performAndWait {
            do {
                return try viewContext.fetch(fetchRequest).map({
                    guard let header = $0.header ?? $0.headerOriginal,
                          !header.isEmpty,
                          let content = $0.content ?? $0.contentOriginal,
                          !content.isEmpty else {
                        return ""
                    }
                    
                    return String(
                        "Header: "
                        +
                        header
                        +
                        "\nContent: "
                        +
                        content
                    )
                }).joined(separator: "\n")
            } catch {
                // TODO: Handle Errors if Necessary
                print("Error fetching generated drawers in DrawerCollectionView... \(error)")
                return ""
            }
        }
    }
    
//    init(action: Action, onGenerate: @escaping (String) -> Void) {
//        self._action = State(initialValue: action)
//        self.onGenerate = onGenerate
//    }
    
    
    var body: some View {
        ZStack {
            if let drawerCollection = action.drawerCollection {
                ScrollView(.vertical) {
                    DrawerCollectionView(
                        drawerCollection: drawerCollection,
                        additionalPromptForRegeneration: "You are an essay outline generator, and are regenerating an outline element.")
                    
                    Spacer(minLength: 140.0)
                }
                .overlay {
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            // Ensure unwrap allDrawersHeaderTitlesForRegenrationForChatWithDrawerCollection, otherwise return TODO: Show alert
                            guard let allDrawersHeaderTitlesForRegenerationForChatWithDrawerCollection = allDrawersHeaderTitlesForRegenerationForChatWithDrawerCollection else {
                                // TODO: Handle Errors, show alert
                                return
                            }
                            
                            // Call onGenerate with allDrawersHeaderTitlesForRegenerationForChatWithDrawerCollection
                            Task {
                                isButtonLoadingAndDisabled = true
                                
                                await onGenerate(allDrawersHeaderTitlesForRegenerationForChatWithDrawerCollection)
                                
                                isButtonLoadingAndDisabled = false
                            }
                            
//                            // Generate chat for first draft
//                            Task {
//                                do {
//                                    try await firstDraftChatGenerator.generate(
//                                        input: (firstDraftPanel.prompt ?? "") + "\n\n" + (allDrawersHeaderTitlesForRegenerationForChatWithDrawerCollection ?? ""),
//                                        image: nil,
//                                        imageURL: nil,
//                                        isPremium: premiumUpdater.isPremium,
//                                        remainingUpdater: remainingUpdater)
//                                } catch {
//                                    // TODO: Handle Errors
//                                    print("Error generating chat in EssayActionCollectionFlowView... \(error)")
//                                }
//                            }
                        }) {
                            ZStack {
                                Text(buttonText)
                                    .font(.custom(Constants.FontName.heavy, size: 24.0))
                                
                                HStack {
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .imageScale(.medium)
                                }
                            }
                            .foregroundStyle(Colors.elementTextColor)
                            .padding()
                            .background(Colors.buttonBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                            .padding()
                        }
                        .disabled(isButtonLoadingAndDisabled)
                        .opacity(isButtonLoadingAndDisabled ? 0.6 : 1.0)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .background(Colors.background)
        .navigationTitle(action.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .toolbar {
            ShareToolbarItem(
                elementColor: .constant(Colors.navigationItemColor),
                placement: .topBarLeading,
                tightenLeadingSpacing: true)
            
            ToolbarItem(placement: .principal) {
                Text(action.title ?? "")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                    .foregroundStyle(Colors.navigationItemColor)
            }
        }
    }
    
}

//#Preview {
//    
//    EssayOutlineActionView()
//    
//}
