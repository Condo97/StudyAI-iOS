//
//  ActionCollectionFlowCreatorView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/21/24.
//

import SwiftUI

struct ActionCollectionFlowCreatorView: View {
    
    @State var conversation: Conversation
    @Binding var presentingAction: Action?
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private let cornerRadius: CGFloat = 20.0
    
//    @State private var actionCollection: ActionCollection?
//    @State private var originalInputAction: Action?
    
    @State private var alertShowingActionExists: Bool = false
    @State private var alertShowingErrorCreatingAction: Bool = false
    
    @State private var isPresentingEssayActionCollectionFlowView: Bool = false
    
    var body: some View {
        VStack {
            // Essay Action Collection
            ConversationInitialActionButton(
                title: "\(Image(systemName: "doc.text")) Essay Builder",
//                subtitle: "Create an outline, first draft, and final draft with AI.",
                action: {
                    createEssayActionCollectionAndOriginalInputAction(type: EssayActionCollectionFlowView.self)
                })
        }
        .alert("Action Exists", isPresented: $alertShowingActionExists, actions: {
            Button(action: {
                
            }) {
                Text("Close")
            }
        }) {
            Text("Create a new Chat to add another action.")
        }
        .alert("Error Creating Action", isPresented: $alertShowingErrorCreatingAction, actions: {
            Button(action: {
                
            }) {
                Text("Close")
            }
        }) {
            Text("Create a new Chat to try again.")
        }
    }
    
    func createEssayActionCollectionAndOriginalInputAction(type actionCollectionFlow: ActionCollectionFlowProtocol.Type) {
        // Ensure conversation does not have actionCollection, otherwise show alert and return though this should already be checked for before showing this view
        guard conversation.actionCollection == nil else {
            alertShowingActionExists = true
            return
        }
        
        // Create actionCollection and action and set presentingAction to it
        Task {
            let actionCollection: ActionCollection
            do {
                actionCollection = try await ActionCollectionCDHelper.createActionCollection(
                    actionCollectionID: actionCollectionFlow.actionCollectionFlowID,
                    title: "Essay Builder",
                    to: conversation,
                    in: viewContext)
            } catch {
                // TODO: Handle Errors, show alert
                print("Error creating action collection in ActionCollectionFlowCreatorView... \(error)")
                alertShowingErrorCreatingAction = true
                return
            }
            
            // Fill actions from ActionCollection
            let fetchRequest = Action.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Action.actionCollection), actionCollection)
            
            let results: [Action]
            do {
                results = try CDClient.mainManagedObjectContext.performAndWait {
                    try CDClient.mainManagedObjectContext.fetch(fetchRequest)
                }
            } catch {
                // TODO: Handle Errors, set isPresented to false for now
                print("Error fetching actions in ActionCollectoinFlowCreatorView... \(error)")
                alertShowingErrorCreatingAction = true
                return
            }
            
            // Check if results contains action with origianlInputActionID and if so set to presentingAction, otherwise insert and set to presentingAction
            if let resultOriginalInputAction = results.first(where: {$0.actionID == EssayActionCollectionFlowView.originalInputActionID}) {
                self.presentingAction = resultOriginalInputAction
            } else {
                if let firstOrderedActionID = actionCollectionFlow.orderedActionIDs[safe: 0] {
                    do {
                        self.presentingAction = try await ActionCDHelper.createAction(
                            actionID: actionCollectionFlow.orderedActionIDs[0],
                            title: "Essay Builder",
                            to: actionCollection,
                            in: CDClient.mainManagedObjectContext)
                    } catch {
                        // TODO: Handle Errors, show alert for now
                        print("Error creating action in ActionCollectionFlowCreatorView... \(error)")
                        alertShowingErrorCreatingAction = true
                    }
                } else {
                    // TODO: Handle Errors, show alert for now
                    print("Could not get or unwrap firstOrderedActionID in ActionCollectionFlowCreatorView!")
                    alertShowingErrorCreatingAction = true
                }
            }
            
            // Set isPresentingEssayActionCollectionFlowView to true
            isPresentingEssayActionCollectionFlowView = true
        }
    }
    
}

//#Preview {
//    ActionCollectionFlowCreatorView()
//}
