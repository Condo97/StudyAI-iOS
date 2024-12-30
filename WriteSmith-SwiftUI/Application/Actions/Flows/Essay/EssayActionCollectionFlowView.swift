//
//  EssayActionCollectionFlowView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/21/24.
//

import SwiftUI

struct EssayActionCollectionFlowView: View, ActionCollectionFlowProtocol {
    
    @State var actionCollection: ActionCollection
    @Binding var presentingAction: Action
    @Binding var isPresented: Bool
    
    static var actionCollectionFlowID: String = EssayActionCollectionFlowView.actionCollectionID
    static var orderedActionIDs: [String] = [
        EssayActionCollectionFlowView.originalInputActionID,
        EssayActionCollectionFlowView.outlineActionID,
        EssayActionCollectionFlowView.firstDraftActionID,
        EssayActionCollectionFlowView.finalDraftActionID
    ]
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @FetchRequest private var actions: FetchedResults<Action>
    
    @State private var isShowingUltraView: Bool = false
    
    static let actionCollectionID: String = "Essay_Action_Collection"
    
    static let originalInputActionID: String = "Builder_Input"
    static let outlineActionID: String = "outline_action"
    static let firstDraftActionID: String = "first_draft_action"
    static let finalDraftActionID: String = "final_draft_action"
    
    static let originalInputPanel: Panel = Panel( // For some reason making this static and initializing panel state from it works while initializing panel state directly with the panel does not work and causes a weird memory leak
        imageName: "",
        title: "Essay Builder Input",
        description: "Create and customize an outline to build an essay.",
        //        prompt: "Create an outline for an essay given the assignment. It should include roman numerals for sections and display the section titles in the Title field. It should include all sections to create a complete essay.",
        prompt: "Create an outline for an essay given the essay prompt. The essay prompt is the topic for the essay. You can pull from the included sources as necessary. Outline output is in a drawer view where the title of the section is in the Title field and the content of the outline section is in the Content field. It should include roman numerals for sections and display the section titles in the Title field. It should include all sections to create a complete essay.",
        components: [
            PanelComponent(
                componentID: "1",
                content: PanelComponentContentType.textField(TextFieldPanelComponentContent(
                    placeholder: "Your essay prompt here...",
                    multiline: true)),
                titleText: "Prompt",
                detailTitle: "Prompt",
                detailText: "Include as many details as possible. This is what the AI will look at when writing.",
                promptPrefix: "ESSAY_PROMPT - This is the Essay Prompt. It is provided as the topic to write the essay about:",
                required: true),
            PanelComponent(
                componentID: "2",
                content: .attachment(AttachmentPanelComponentContent(maxAttachments: 5)),
                titleText: "Add Sources",
                detailTitle: "Add Sources",
                detailText: "Attach source documents, voice, videos, and webpages.",
                promptPrefix: "ESSAY_SOURCES - These are the sources to pull from when writing the essay about the prompt:",
                required: false)
        ])
    
    @State private var originalInputPanel: Panel = EssayActionCollectionFlowView.originalInputPanel
    
    static let outlineGenerationPrompt: String = "Provided is the outline of the essay to be created. Generate a first draft based on it."
    
    static let firstDraftPanel: Panel = Panel(
        emoji: "📝",
        title: "Rough Draft",
        description: "Edit your first draft and finalize to check it once more.",
        //        prompt: "Provided is the outline of the essay to be created. Generate a first draft based on it.", // This is replaced with the final draft prompt since this prompt would be in the outline if it were a panel and not a drawer collection
        prompt: "YOU ARE A FINAL ESSAY WRITER. Make the essay draft from the first draft by looking it over and rewriting it as necessary including combining sections to form one comprehensive essay. Convert the first draft essay to a final draft. Fix any mistakes, remove draft notes, and revise it for a complete and correctly fomratted final draft. You are to proofread, correct, rewrite, combine, and more for the inputted first draft essay. You are to ensure that it is formatted MLA or APA or some proper format. It should be fully finalized and in essay format combining sections logically and rewriting as necessary.",
        components: [
            PanelComponent(
                componentID: firstDraftInputComponentID,
                content: .textField(
                    TextFieldPanelComponentContent(
                        placeholder: "First Draft...",
                        multiline: true)
                ),
                titleText: "First Draft",
                detailTitle: "First Draft",
                detailText: "Change up your first draft and AI will look it over another time.",
                promptPrefix: "First Draft:\n",
                required: true)
        ])
    static let firstDraftInputComponentID = "1" // This is so that the input can be filled with the chat generator once the user generates a first draft on outline
    
    @State private var firstDraftPanel: Panel = EssayActionCollectionFlowView.firstDraftPanel
    
    static let finalDraftPanel: Panel = Panel(
        emoji: "📄",
        title: "Final Draft",
        description: "Edit your final draft and continue to save in chat.",
        prompt: nil,
        components: [
            PanelComponent(
                componentID: "1",
                content: .textField(
                    TextFieldPanelComponentContent(
                        placeholder: "Final Draft...",
                        multiline: true)
                ),
                titleText: "Final Draft",
                detailTitle: "Final Draft",
                detailText: "Edit your final draft to make it yours.",
                promptPrefix: "Final Draft:\n",
                required: true)
        ])
    static let finalDraftInputComponentID = "1" // This is so that the input can be filled with the chat generator once the user generates a final draft on first draft
    
    @State private var finalDraftPanel: Panel = EssayActionCollectionFlowView.finalDraftPanel
    
    
    @StateObject var outlineGenerator: DrawerGenerator = DrawerGenerator()
    @StateObject var firstDraftChatGenerator: SimpleChatGenerator = SimpleChatGenerator()
    @StateObject var finalDraftChatGenerator: SimpleChatGenerator = SimpleChatGenerator()
    
    @State private var alertShowingNoFirstDraft: Bool = false
    
    @State private var isLoadingOutline: Bool = false
    
    //    @State private var originalInputAction: Action?
    //    @State private var outlineAction: Action?
    //    @State private var firstDraftAction: Action?
    //    @State private var finalDraftAction: Action?
    
    var originalInputAction: Action? {
        actions.first(where: {$0.actionID == EssayActionCollectionFlowView.originalInputActionID})
    }
    
    var outlineAction: Action? {
        actions.first(where: {$0.actionID == EssayActionCollectionFlowView.outlineActionID})
    }
    
    var firstDraftAction: Action? {
        actions.first(where: {$0.actionID == EssayActionCollectionFlowView.firstDraftActionID})
    }
    
    var finalDraftAction: Action? {
        actions.first(where: {$0.actionID == EssayActionCollectionFlowView.finalDraftActionID})
    }
    
    //    var isPresentingOutlineAction: Binding<Bool> {
    //        Binding(get: {
    //            // TODO: Since this is just a get, does it even need to be in a binding?
    //            outlineAction != nil
    //        },
    //        set: { value in
    //
    //        })
    //    }
    //
    //    var isPresentingFirstDraftAction: Binding<Bool> {
    //        Binding(get: {
    //            // TODO: Since this is just a get, does it even need to be in a binding?
    //            firstDraftAction != nil
    //        },
    //        set: { value in
    //
    //        })
    //    }
    //
    //    var isPresentingFinalDraftAction: Binding<Bool> {
    //        Binding(get: {
    //            // TODO: Since this is just a get, does it even need to be in a binding?
    //            finalDraftAction != nil
    //        },
    //        set: { value in
    //
    //        })
    //    }
    
    /***
     All of the original input attachments' cached text. Super useful for building prompts! It's all of the attachments for the essay :)
     */
    var allOriginalInputAttachmentsCachedText: String? { // Easy way to refer to sources throughout the entire process
        guard let originalInputAction = originalInputAction,
              let panelContent = originalInputAction.panelContent else {
            // TODO: Handle Errors if Necessary
            print("Could not unwrap panelContent in EssayActionCollectionFlowView!")
            return nil
        }
        
        // Get panel component content for originalInputAction panels
        let panelComponentContentFetchRequest = PanelComponentContent.fetchRequest()
        panelComponentContentFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PanelComponentContent.panelContent), panelContent)
        
        let panelComponentsContent: [PanelComponentContent]
        do {
            panelComponentsContent = try viewContext.performAndWait {
                try viewContext.fetch(panelComponentContentFetchRequest)
            }
        } catch {
            // TODO: Handle Errors
            print("Error fetching panel component content in EssayActionCollectionFlowView... \(error)")
            return nil
        }
        
        // Get attachments for each panel component
        var attachmentPersistentText: [String] = []
        for panelComponentContent in panelComponentsContent {
            let persistentAttachmentsFetchRequest = PersistentAttachment.fetchRequest()
            persistentAttachmentsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.panelComponentContent), panelComponentContent)
            
            let attachments: [PersistentAttachment]
            do {
                attachments = try viewContext.performAndWait {
                    try viewContext.fetch(persistentAttachmentsFetchRequest)
                }
            } catch {
                // TODO: Handle Errors
                print("Error fetching persistent attachments in EssayActionCollectionFlowView... \(error)")
                continue
            }
            
            // Append each Attachment's cached text to attachmentsPersistentText
            for attachment in attachments {
                if let cachedText = attachment.cachedText {
                    attachmentPersistentText.append(cachedText)
                }
            }
        }
        
        // Return attachments' persistent text with Attachments:\n prefix and END_OF_ATTACHMENTS\n\n suffix
        return "Attachments:\n" + attachmentPersistentText.joined(separator: "\n") + "END_OF_ATTACHMENTS\n\n"
    }
    
    init(actionCollection: ActionCollection, presentingAction: Binding<Action>, isPresented: Binding<Bool>) {
        self._actionCollection = State(initialValue: actionCollection)
        self._presentingAction = presentingAction
        self._isPresented = isPresented
        
        self._actions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Action.date), ascending: false)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Action.actionCollection), actionCollection),
            animation: .default)
        
        //        // Fill actions from ActionCollection
        //        let fetchRequest = Action.fetchRequest()
        //        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Action.actionCollection), actionCollection)
        //
        //        let results: [Action]
        //        do {
        //            results = try CDClient.mainManagedObjectContext.performAndWait {
        //                try CDClient.mainManagedObjectContext.fetch(fetchRequest)
        //            }
        //        } catch {
        //            // TODO: Handle Errors, set isPresented to false for now
        //            print("Error fetching actions in EssayActionCollectionFlowView... \(error)")
        //            isPresented.wrappedValue = false
        //            return
        //        }
        //
        //        // Check if results contains action with origianlInputActionID and if so set to presentingAction, otherwise insert and set to presentingAction
        //        if let resultOriginalInputAction = results.first(where: {$0.actionID == EssayActionCollectionFlowView.originalInputActionID}) {
        //            self.presentingAction = resultOriginalInputAction
        //        } else {
        //            do {
        //                try ActionCDHelper.createAction(
        //                    actionID: EssayActionCollectionFlowView.originalInputActionID,
        //                    title: "Essay Builder",
        //                    to: actionCollection,
        //                    in: CDClient.mainManagedObjectContext)
        //            } catch {
        //                // TODO: Handle Errors, set isPresented to false for now
        //                print("Error creating action in ActionCDHelper... \(error)")
        //                isPresented.wrappedValue = false
        //            }
        //        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if presentingAction == originalInputAction,
                   let originalInputAction = originalInputAction,
                   let actionCollection = originalInputAction.actionCollection {
                    EssayOriginalInputActionView(action: originalInputAction, panel: $originalInputPanel, buttonText: "Generate...", isLoading: $isLoadingOutline, onGenerate: { finalizedPrompt in
                        // Ensure authToken, otherwise return TODO: Handle errors
                        let authToken: String
                        do {
                            authToken = try await AuthHelper.ensure()
                        } catch {
                            // TODO: Handle errors
                            print("Error ensureing AuthToken in EssayActionCollectionFlowView... \(error)")
                            return
                        }
                        
                        // Generate drawer collection
                        let drawerCollection: GeneratedDrawerCollection
                        do {
                            drawerCollection = try await outlineGenerator.generateDrawerCollection(
                                text: finalizedPrompt,
                                imageData: nil,
                                authToken: authToken,
                                in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error generating drawer collection in EssayActionCollectionFlowView... \(error)")
                            return
                        }
                        
                        // Create action with drawerCollection and set to presentingAction
                        do {
                            self.presentingAction = try await ActionCDHelper.createAction(
                                actionID: EssayActionCollectionFlowView.outlineActionID,
                                title: "Outline",
                                drawerCollection: drawerCollection,
                                to: actionCollection,
                                in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error creating action in EssayActionCollectionFlowView... \(error)")
                        }
                        
                    })
                }
                
                if presentingAction == outlineAction,
                   let outlineAction = outlineAction,
                   let actionCollection = outlineAction.actionCollection  {
                    EssayOutlineActionView(action: outlineAction, buttonText: "Generate Essay...", onGenerate: { finalizedPrompt in
                        // Generate chat for first draft or show premium popup
                        if premiumUpdater.isPremium {
                            Task {
                                do {
                                    try await firstDraftChatGenerator.generate(
                                        input: EssayActionCollectionFlowView.outlineGenerationPrompt + "\n\n" + finalizedPrompt,
                                        //                                        input: (EssayActionCollectionFlowView.originalInputPanel.prompt ?? "") + "\n\n" + (allOriginalInputAttachmentsCachedText ?? "") + finalizedPrompt/*(allDrawersHeaderTitlesForRegenerationForChatWithDrawerCollection ?? "") this is now finalizedPrompt!*/,
                                        image: nil,
                                        imageURL: nil,
                                        isPremium: premiumUpdater.isPremium)
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error generating chat in EssayActionCollectionFlowView... \(error)")
                                }
                            }
                        } else {
                            isShowingUltraView = true
                        }
                    })
                    .disabled(firstDraftChatGenerator.isLoading || firstDraftChatGenerator.isGenerating)
                    .opacity(firstDraftChatGenerator.isLoading || firstDraftChatGenerator.isGenerating ? 0.6 : 1.0)
                    .alert("No First Draft", isPresented: $alertShowingNoFirstDraft, actions: {
                        Button("Close", action: {
                            
                        })
                    }) {
                        Text("Please add a first draft or go back and re-create one. You must have a first draft to generate a final draft.")
                    }
                }
                
                if presentingAction == firstDraftAction,
                   let firstDraftAction = firstDraftAction,
                   let actionCollection = firstDraftAction.actionCollection  {
                    EssayOriginalInputActionView(action: firstDraftAction, panel: $firstDraftPanel, buttonText: "Generate Final Draft...", isLoading: $firstDraftChatGenerator.isGenerating, onGenerate: { finalizedPrompt in
                        //                                    // Ensure unwrap firstDraftText, otherwise show error alert and return
                        //                                    guard let firstDraftText = firstDraftText else {
                        //                                        // TODO: Handle Errors
                        //                                        alertShowingNoFirstDraft = true
                        //                                        return
                        //                                    }
                        
                        // Generate chat for final draft
                        Task {
                            do {
                                try await finalDraftChatGenerator.generate(
                                    input: finalizedPrompt,
                                    image: nil,
                                    imageURL: nil,
                                    isPremium: premiumUpdater.isPremium)
                            } catch {
                                // TODO: Handle Errors
                                print("Error generating chat in EssayActionCollectionFlowView... \(error)")
                            }
                        }
                    })
                    .disabled(finalDraftChatGenerator.isLoading || finalDraftChatGenerator.isGenerating)
                    .opacity(finalDraftChatGenerator.isLoading || finalDraftChatGenerator.isGenerating ? 0.6 : 1.0)
                }
                
                if presentingAction == finalDraftAction,
                   let finalDraftAction = finalDraftAction,
                   let actionCollection = finalDraftAction.actionCollection  {
                    let currentChat = finalDraftChatGenerator.generatedTexts.max(by: {$0.key < $1.key})?.value ?? ""
//                    ExploreChatView(chat: currentChat)
//                        .onReceive(of: finalDraftChatGenerator.$isGenerating) { newValue in
//                            // On finish generating save because typically it would have in EssayOriginalInputActionView, update ActionCollection displayText with finalizedPrompt, and dismiss
//                        }
                    
                    EssayOriginalInputActionView(action: finalDraftAction, panel: $finalDraftPanel, buttonText: "Save", isLoading: $finalDraftChatGenerator.isGenerating, onGenerate: { finalizedPrompt in
                        // Update ActionCollection displayText with finalizedPrompt and dismiss TODO: This will have already saved it to PanelContent
                        do {
                            try ActionCollectionCDHelper.update(
                                displayText: finalizedPrompt,
                                for: actionCollection,
                                in: viewContext)
                        } catch {
                            // TODO: Handle Errors if Necessary
                            print("Error updating ActionCollection in EssayActionCollectionFlowView... \(error)")
                        }
                        
                        self.isPresented = false
                    })
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        // Delete actionCollection from CoreData if it is empty TODO: This whole logic is silly, it shouldn't create it until after the first part is added
                        Task {
                            let actionCollectionIsEmpty: Bool
                            do {
                                actionCollectionIsEmpty = try viewContext.performAndWait {
                                    let fetchRequest = Action.fetchRequest()
                                    fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Action.actionCollection), actionCollection)
                                    fetchRequest.fetchLimit = 2
                                    
                                    let results = try viewContext.fetch(fetchRequest)
                                    
                                    if results.count == 0 {
                                        // If there are no actions return true
                                        return true
                                    } else if results.count == 1 {
                                        // If there is one action check if it is the first action ID and its panel content is emtpy and if so return true
                                        if results[0].actionID == Self.orderedActionIDs[0],
                                           results[0].panelContent == nil {
                                            return true
                                        }
                                    }
                                    
                                    return false
                                }
                            } catch {
                                // TODO: Handle Errors
                                print("Error getting if action collection is empty in EssayActionCollectionFlowView, defaulting to false and continuing... \(error)")
                                actionCollectionIsEmpty = false
                            }
                            
                            if actionCollectionIsEmpty {
                                do {
                                    try await CDClient.delete(actionCollection, in: viewContext)
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error deleting actionCollection in EssayActionCollectionFlowView, continuing... \(error)")
                                }
                            }
                            
                            await MainActor.run {
                                isPresented = false
                            }
                        }
                    }) {
                        Text("Close")
                    }
                    .padding(.trailing, -12.0)
                }
            }
        }
        .onReceive(firstDraftChatGenerator.$generatedTexts) { newValue in
            // If newValue is not empty create action if firstDraftAction is nil and set component input
            if !newValue.isEmpty {
                // Get currentChat as the highest index value
                let currentChat = newValue.max(by: {$0.key < $1.key})?.value ?? ""
                
                // If firstDraftAction is not equal to presentingAction set or create firstDraftAction
                if firstDraftAction != presentingAction {
//                    // When firstDraftAction is nil add action.. chcek out here so we're not always checking on the main queue TODO: Is this fine to do? I mean it's going on the main queue
//                    if let firstDraftAction = firstDraftAction {
//                        // Set presentingAction to firstDraftAction since the user may be updating the first draft
//                        presentingAction = firstDraftAction
//                    } else {
//                        DispatchQueue.main.async {
//                            // Check if firstDraftAction is nil and if so create action and set to presentingAction
//                            if firstDraftAction == nil {
                                do {
                                    self.presentingAction = try ActionCDHelper.createAction(
                                        actionID: EssayActionCollectionFlowView.firstDraftActionID,
                                        title: "First Draft",
                                        to: actionCollection,
                                        in: viewContext)
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error creating action in EssayActionCollectionFlowView... \(error)")
                                }
//                            }
//                        }
//                    }
                }
                
                // Set firstDraftPanel first component input to generatedText
                if let firstDraftPanelInputComponentIndex = firstDraftPanel.components.firstIndex(where: {$0.componentID == EssayActionCollectionFlowView.firstDraftInputComponentID}) {
                    firstDraftPanel.components[firstDraftPanelInputComponentIndex].input = currentChat
                }
            }
        }
        .onReceive(finalDraftChatGenerator.$generatedTexts) { newValue in
            // If generatedText is not empty create action if finalDraftAction is nil and set component input
            if !newValue.isEmpty {
                // Get currentChat as the highest index value
                let currentChat = newValue.max(by: {$0.key < $1.key})?.value ?? ""
                
                // If finalDraftAction is not equal to presentingAction set or create finalDraftAction
                if finalDraftAction != presentingAction {
//                    // When finalDraftAction is nil add action.. chcek out here so we're not always checking on the main queue TODO: Is this fine to do? I mean it's going on the main queue
//                    if let finalDraftAction = finalDraftAction {
//                        // Set presentingAction to finalDraftAction since the user may be updating the first draft
//                        presentingAction = finalDraftAction
//                    } else {
//                        DispatchQueue.main.async {
                            // Check if firstDraftAction is nil and if so create action and set to presentingAction
//                            if finalDraftAction == nil {
                                do {
                                    self.presentingAction = try ActionCDHelper.createAction(
                                        actionID: EssayActionCollectionFlowView.finalDraftActionID,
                                        title: "Final Draft",
                                        to: actionCollection,
                                        in: viewContext)
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error creating action in EssayActionCollectionFlowView... \(error)")
                                }
//                            }
//                        }
//                    }
                }
                
                // Set firstDraftPanel first component input to generatedText
                if let finalDraftPanelInputComponentIndex = finalDraftPanel.components.firstIndex(where: {$0.componentID == EssayActionCollectionFlowView.finalDraftInputComponentID}) {
                    finalDraftPanel.components[finalDraftPanelInputComponentIndex].input = currentChat
                }
            }
        }
        .ultraViewPopover(isPresented: $isShowingUltraView)
    }
    
}

//#Preview {
//
//    EssayActionCollectionFlowView()
//
//}

