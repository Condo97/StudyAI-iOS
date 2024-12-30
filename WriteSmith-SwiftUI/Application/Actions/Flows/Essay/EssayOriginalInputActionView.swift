//
//  EssayOriginalInputActionView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/21/24.
//

import SwiftUI

struct EssayOriginalInputActionView: View, ActionViewProtocol {
    
    @State var action: Action
    @Binding var panel: Panel
    @State var buttonText: String
    @Binding var isLoading: Bool
    var onGenerate: (String) async -> Void
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    
//    init(action: Action, panel: Binding<Panel>, buttonText: String, isLoading: Binding<Bool>, onGenerate: @escaping (String) async -> Void) {
//        self._action = State(initialValue: action)
//        self._panel = panel
//        self._buttonText = State(initialValue: buttonText)
//        self._isLoading = isLoading
//        self.onGenerate = onGenerate
//        
////        // If action panelContent is not nil update each originalInputPanel input value with cachedInput from corresponding panelComponentContent
////        if let panelContent = action.panelContent {
////            // Update originalInputPanel input values from action panelComponentsContent
////            let fetchRequest = PanelComponentContent.fetchRequest()
////            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PanelComponentContent.panelContent), panelContent)
////            
////            do {
////                try CDClient.mainManagedObjectContext.performAndWait {
////                    // Get results and set to corresponding input values
////                    let results = try CDClient.mainManagedObjectContext.fetch(fetchRequest)
////                    for result in results {
////                        if let resultCachedInput = result.cachedInput {
////                            for i in 0..<panel.components.count {
////                                panel.wrappedValue.components[i].input = resultCachedInput
////                            }
////                        }
////                    }
////                }
////            } catch {
////                print("Error updating original input panel input values from panelComponentsContent... \(error)")
////            }
////        }
//    }
    
    
    var body: some View {
//        ScrollViewReader { proxy in
            PanelView(
                panel: $panel,
                isLoading: $isLoading,
                buttonText: buttonText,
                onGenerate: { finalizedPrompt in
                    Task {
                        // Defer setting isButtonLoadingAndDisabled to false
                        defer {
                            DispatchQueue.main.async {
                                isLoading = false
                            }
                        }
                        
                        // Set isButtonLoadingAndDisabled to true
                        DispatchQueue.main.async {
                            isLoading = true
                        }
                        
                        // Create or update panel components content
                        do {
                            try await createOrUpdatePanelComponentsContent()
                        } catch {
                            // TODO: Handle Errors
                            print("Error creating or updating panel components content in EssayOriginalInputActionView... \(error)")
                        }
                        
                        // Call onGenerate
                        await onGenerate(finalizedPrompt)
                    }
                })
//        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Colors.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(action.title ?? "")
                    .font(.custom(Constants.FontName.black, size: 24.0))
                    .foregroundStyle(Colors.navigationItemColor)
            }
        }
        .onAppear {
            // If action panelContent is not nil update each originalInputPanel input value with cachedInput from corresponding panelComponentContent
            if let panelContent = action.panelContent {
                // Update originalInputPanel input values from action panelComponentsContent
                let fetchRequest = PanelComponentContent.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PanelComponentContent.panelContent), panelContent)
                
                do {
                    try viewContext.performAndWait {
                        // Get results and set to corresponding input and persistentAttachment values
                        let results = try viewContext.fetch(fetchRequest)
                        for result in results {
                            for i in 0..<panel.components.count {
                                if result.componentID == panel.components[i].componentID {
                                    // Set input
                                    if let resultCachedInput = result.cachedInput {
                                        panel.components[i].input = resultCachedInput
                                    }
                                    
                                    // Set persistentAttachments
                                    let persistentAttachmentsFetchRequest = PersistentAttachment.fetchRequest()
                                    persistentAttachmentsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.panelComponentContent), result)
                                    
                                    do {
                                        let persistentAttachmentsResults = try viewContext.fetch(persistentAttachmentsFetchRequest)
                                        
                                        // Set persistentAttachmentResults to persistentAttachments for panel component at index i TODO: Is this good practice to do or do I need to copy it better?
                                        panel.components[i].persistentAttachments = persistentAttachmentsResults
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error fetching persistent attachments in EssayOriginalInputActionView... \(error)")
                                    }
                                    
                                }
                            }
                        }
                    }
                } catch {
                    print("Error updating original input panel input values from panelComponentsContent... \(error)")
                }
            }
        }
        .onChange(of: isLoading) { newValue in
            // Create or update panel components content when finished loading
            if !newValue {
                Task {
                    do {
                        try await createOrUpdatePanelComponentsContent()
                    } catch {
                        // TODO: Handle Errors
                        print("Error creating or updating panel components content in EssayOriginalInputActionView... \(error)")
                    }
                }
            }
        }
    }
    
    func createOrUpdatePanelComponentsContent() async throws {
        // Create or unwrap panelContent from action
        let panelContent: PanelContent
        if let actionPanelContent = action.panelContent {
            panelContent = actionPanelContent
        } else {
            panelContent = try await PanelContentCDHelper.createPanelContent(to: action, in: viewContext)
        }
        
        // Create updatedComponentIDs to store all ids already updated in CoreData and therefore that should not be inserted
        var updatedComponentIDs: [String] = []
        
        // Fetch panel components content form PanelContent
        let fetchRequest = PanelComponentContent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PanelComponentContent.panelContent), panelContent)
        
        let results = try await viewContext.perform {
            try viewContext.fetch(fetchRequest)
        }
        
        // Update each result cachedInput and add componentID to updatedComponentIDs
        for result in results {
            if let componentID = result.componentID {
                if let panelContentInput = panel.components.first(where: {$0.componentID == componentID})?.input {
                    try await PanelComponentContentCDHelper.updatePanelComponentContent(result, withCachedInput: panelContentInput, in: viewContext)
                    updatedComponentIDs.append(componentID)
                }
            }
        }
        
        // Create PanelComponentContent for each component with componentID not in updatedComponentIDs
        for component in panel.components {
            // Ensure componentID is not in updatedComponentIDs, otherwise continue
            guard !updatedComponentIDs.contains(where: {$0 == component.componentID}) else {
                continue
            }
            
            do {
                // Create panelComponentContent to panelContent
                try await PanelComponentContentCDHelper.createPanelComponentContent(
                    componentID: component.componentID,
                    input: component.input,
                    persistentAttachments: component.persistentAttachments,
                    to: panelContent,
                    in: viewContext)
            } catch {
                // TODO: Handle Errors
                print("Error creating panel component content in EssayActionCollectionFlowView... \(error)")
                continue
            }
        }
    }
    
}

//#Preview {
//    EssayOriginalInputActionView()
//}
