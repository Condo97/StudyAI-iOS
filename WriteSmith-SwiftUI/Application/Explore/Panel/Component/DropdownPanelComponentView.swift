//
//  DropdownPanelComponentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

struct DropdownPanelComponentView<T: PanelComponentProtocol>: PanelComponentViewProtocol {
    
    @Binding var component: T
    @State var dropdownComponentContent: DropdownPanelComponentContent
    
//    @State var titleText: String
////    @State var selectedOption: String
//    @State var options: [String]
//    @State var promptPrefix: String?
//    @State var required: Bool
//    
//    @Binding var finalizedPrompt: String?
//    @Binding var input: String
    
    
    private let noneItem: String = "- None -"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            TitlePanelComponentView(
                text: component.titleText,
                required: component.requiredUnwrapped)
            
            HStack {
                Menu {
                    Picker(
                        "",
                        selection: $component.input,
                        content: {
                            ForEach(component.requiredUnwrapped ? dropdownComponentContent.options : ([noneItem] + dropdownComponentContent.options), id: \.self) { option in
                                Text(option)
                                    .font(.custom(Constants.FontName.body, size: 17.0))
                            }
                        })
                    .onChange(of: component.input) { newSelectedOption in
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Update finalized prompt
                        updateFinalizedPrompt()
                    }
                } label: {
                    HStack {
                        Text(component.input)
                            .font(.custom(Constants.FontName.body, size: 17.0))
                        Image(systemName: "chevron.up.chevron.down")
                    }
                }
                    
                Spacer()
            }
            .font(.custom(Constants.FontName.body, size: 17.0))
            .foregroundStyle(Colors.text)
            .tint(Colors.text)
            .padding()
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .onTapGesture {
                // Do light haptic
                HapticHelper.doLightHaptic()
            }
            
        }
    }
    
    private func updateFinalizedPrompt() {
        // Ensure an item is selected by checking if selected is not empty, otherwise set finalizedPrompt to nil and return
        guard !component.input.isEmpty else {
            component.finalizedPrompt = nil
            return
        }
        
        // Ensure selected item is not noneItem, otherwise set finalizedPrompt to nil and return
        guard component.input != noneItem else {
            component.finalizedPrompt = nil
            return
        }
        
        // Set finalizedPrompt to panelComponent prompt prefix if not nil, a space, and selected item
        component.finalizedPrompt = (component.promptPrefix == nil ? "" : component.promptPrefix! + " ") + component.input
    }
    
}

//#Preview {
//    
//    let dropdownComponentContent = DropdownPanelComponentContent(
//        placeholder: nil,
//        options: [
//            "Option 1",
//            "Option 2",
//            "Option 3"
//        ])
//    
//    return DropdownPanelComponentView(
//        component: .constant(
//            PanelComponent(
//                componentID: "1",
//                content: .dropdown(dropdownComponentContent),
//                titleText: "Title text",
//                required: true)),
//        dropdownComponentContent: dropdownComponentContent
//    )
//    .background(Colors.background)
//}
