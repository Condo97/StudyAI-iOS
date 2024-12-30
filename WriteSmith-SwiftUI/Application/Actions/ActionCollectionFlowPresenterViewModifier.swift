//
//  ActionCollectionFlowPresenterViewModifier.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/22/24.
//

import SwiftUI

struct ActionCollectionFlowPresenterViewModifier: ViewModifier {
    
    @State var actionCollection: ActionCollection
    @Binding var presentingAction: Action
    @Binding var isPresented: Bool
    
    
    func body(content: Content) -> some View {
        switch actionCollection.actionCollectionID {
        case ActionCollectionFlows.essay.actionCollectionFlowType.actionCollectionFlowID:
            EssayActionCollectionFlowView(
                actionCollection: actionCollection,
                presentingAction: $presentingAction,
                isPresented: $isPresented)
        default:
            ZStack {
                Text("No ActionCollectionFlow")
            }
        }
    }
    
}

extension View {
    
    func actionCollectionFlowPresenter(presentingAction: Binding<Action?>) -> some View {
        var isPresented: Binding<Bool> {
            Binding(
                get: {
                    presentingAction.wrappedValue != nil
                },
                set: { value in
                    if !value {
                        presentingAction.wrappedValue = nil
                    }
                })
        }
        
        return self
            .fullScreenCover(isPresented: isPresented) {
                if let presentingActionUnwrapped = presentingAction.wrappedValue,
                   let presentingActionCollection = presentingActionUnwrapped.actionCollection {
                    var presentingActionUnwrappedBinding: Binding<Action> {
                        Binding(
                            get: {
                                presentingActionUnwrapped
                            },
                            set: { value in
                                presentingAction.wrappedValue = value
                            })
                    }
                    
                    VStack {
                        modifier(ActionCollectionFlowPresenterViewModifier(actionCollection: presentingActionCollection, presentingAction: presentingActionUnwrappedBinding, isPresented: isPresented))
                    }
                }
            }
    }
    
}


//#Preview {
//    ActionCollectionFlowPresenterViewModifier()
//}
