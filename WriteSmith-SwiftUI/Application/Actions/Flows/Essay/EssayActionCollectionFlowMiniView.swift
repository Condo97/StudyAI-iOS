//
//  EssayActionCollectionFlowMiniView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/22/24.
//

import SwiftUI

struct EssayActionCollectionFlowMiniView: View {
    
    @State var actionCollection: ActionCollection
    @Binding var selectedAction: Action?
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest private var actions: FetchedResults<Action>
    
    @State private var isDisplayingActions: Bool = false
    
    init(actionCollection: ActionCollection, selectedAction: Binding<Action?>) {
        self._actionCollection = State(initialValue: actionCollection)
        self._selectedAction = selectedAction
        
        self._actions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Action.date), ascending: false)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Action.actionCollection), actionCollection),
            animation: .default)
    }
    
    // TODO: This needs to be made more universal for any action collection flow protocol
    
    var body: some View {
        ZStack {
            Button(action: {
                isDisplayingActions.toggle()
            }) {
                ZStack {
                    VStack {
                        ZStack {
                            HStack {
                                // Title and Subtitle
                                VStack(alignment: .leading) {
                                    if let title = actionCollection.title {
                                        Text(title)
                                            .font(.custom(Constants.FontName.body, size: 20.0))
                                    }
                                    
                                    // Subtitle or Date
                                    if let subtitle = actionCollection.subtitle {
                                        Text(subtitle)
                                            .font(.custom(Constants.FontName.black, size: 12.0))
                                    } else if let date = actionCollection.date {
                                        let dateFormatter: DateFormatter = {
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "MMM d, h:mm a"
                                            
                                            return dateFormatter
                                        }()
                                        
                                        Text(dateFormatter.string(from: date))
                                            .font(.custom(Constants.FontName.black, size: 12.0))
                                    }
                                }
                                
                                Spacer()
                                
                                // Chevron
                                Image(systemName: isDisplayingActions ? "chevron.down" : "chevron.up")
                                    .imageScale(.large)
                            }
                            .foregroundStyle(Colors.text)
                        }
                        
                        // Show actions if isDisplayingActions, each in cascading if conditions since each action is dependent on the existence of its previous action
                        if isDisplayingActions {
                            Divider()
                            
                            VStack {
                                // Original prompt action
                                if let originalPromptAction = actions.first(where: {$0.actionID == EssayActionCollectionFlowView.originalInputActionID}) {
                                    Button(action: {
                                        // TODO: Resume EssayActionCollectionFlowView to original prompt action
                                        selectedAction = originalPromptAction
                                    }) {
                                        ZStack {
                                            Text(originalPromptAction.title ?? "No Title")
                                                .font(.custom(Constants.FontName.body, size: 17.0))
                                            
                                            HStack {
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .imageScale(.medium)
                                            }
                                        }
                                    }
                                    .foregroundStyle(Colors.textOnBackgroundColor)
                                    .padding()
                                    .background(Colors.background)
                                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                    
                                    // Outline action
                                    if let outlineAction = actions.first(where: {$0.actionID == EssayActionCollectionFlowView.outlineActionID}) {
                                        Button(action: {
                                            // TODO: Resume EssayActionCollectionFlowView to outline action
                                            selectedAction = outlineAction
                                        }) {
                                            ZStack {
                                                Text(outlineAction.title ?? "No Title")
                                                    .font(.custom(Constants.FontName.body, size: 17.0))
                                                
                                                HStack {
                                                    Spacer()
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .imageScale(.medium)
                                                }
                                            }
                                        }
                                        .foregroundStyle(Colors.textOnBackgroundColor)
                                        .padding()
                                        .background(Colors.background)
                                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                        
                                        // First draft action
                                        if let firstDraftAction = actions.first(where: {$0.actionID == EssayActionCollectionFlowView.firstDraftActionID}) {
                                            Button(action: {
                                                // TODO: Resume EssayActionCollectionFlowView to first draft action
                                                selectedAction = firstDraftAction
                                            }) {
                                                ZStack {
                                                    Text(firstDraftAction.title ?? "No Title")
                                                        .font(.custom(Constants.FontName.body, size: 17.0))
                                                    
                                                    HStack {
                                                        Spacer()
                                                        
                                                        Image(systemName: "chevron.right")
                                                            .imageScale(.medium)
                                                    }
                                                }
                                            }
                                            .foregroundStyle(Colors.textOnBackgroundColor)
                                            .padding()
                                            .background(Colors.background)
                                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                            
                                            // Final draft action
                                            if let finalDraftAction = actions.first(where: {$0.actionID == EssayActionCollectionFlowView.finalDraftActionID}) {
                                                Button(action: {
                                                    // TODO: Resume EssayActionCollectionFlowView to final draft action
                                                    selectedAction = finalDraftAction
                                                }) {
                                                    ZStack {
                                                        Text(finalDraftAction.title ?? "No Title")
                                                            .font(.custom(Constants.FontName.body, size: 17.0))
                                                        
                                                        HStack {
                                                            Spacer()
                                                            
                                                            Image(systemName: "chevron.right")
                                                                .imageScale(.medium)
                                                        }
                                                    }
                                                }
                                                .foregroundStyle(Colors.textOnBackgroundColor)
                                                .padding()
                                                .background(Colors.background)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
        }
//            }
//            .navigationDestination(isPresented: $isPresentingEssayActionColletionFlowView) {
//                EssayActionCollectionFlowView(actionCollection: actionCollection, isPresented: $isPresentingEssayActionColletionFlowView)
//            }
//        }
    }
    
}

//#Preview {
//    EssayActionCollectionFlowMiniView()
//}
