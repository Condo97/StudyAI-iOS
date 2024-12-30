//
//  TextFieldPanelComponentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import MarkdownUI
import SwiftUI

struct TextFieldPanelComponentView<T: PanelComponentProtocol>: PanelComponentViewProtocol, KeyboardReadable {
    
    @Binding var component: T
    @State var textFieldComponentContent: TextFieldPanelComponentContent
    
//    @State var titleText: String
//    @State var placeholder: String
//    @State var multiline: Bool
//    @State var promptPrefix: String?
//    @State var required: Bool
//    
//    @Binding var finalizedPrompt: String?
//    @Binding var input: String
    
    
//    @State private var textFieldText: String = ""
    
    var body: some View {
        VStack(spacing: 4.0) {
            TitlePanelComponentView(
                text: component.titleText,
                required: component.requiredUnwrapped)
            TextField("", text: $component.input, axis: textFieldComponentContent.multilineUnwrapped ? .vertical : .horizontal)
                .lineLimit(textFieldComponentContent.multilineUnwrapped ? 999 : 1)
                .frame(minHeight: textFieldComponentContent.multilineUnwrapped ? 80.0 : 0.0, alignment: .topLeading)
                .textFieldTickerTint(Colors.text)
                .placeholder(
                    when: component.input.isEmpty,
                    alignment: .topLeading,
                    placeholder: {
                        Text(textFieldComponentContent.placeholderUnwrapped)
                            .opacity(0.6)
                    })
                .dismissOnReturn()
                .font(.custom(Constants.FontName.body, size: 17.0))
                .foregroundStyle(Colors.text)
                .padding()
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                .onChange(of: component.input) { newValue in
                    updateFinalizedPrompt()
                }
        }
    }
    
    private func updateFinalizedPrompt() {
        guard !component.input.isEmpty else {
            component.finalizedPrompt = nil
            return
        }
        
        component.finalizedPrompt = (component.promptPrefix == nil ? "" : component.promptPrefix! + " ") + component.input
    }
    
}

//@available(iOS 17.0, *)
//#Preview(traits: .sizeThatFitsLayout) {
//    
//    let textFieldComponentContent = TextFieldPanelComponentContent(
//        placeholder: "Placeholder",
//        multiline: true)
//    
//    return TextFieldPanelComponentView(
//        component: .constant(PanelComponent(
//            componentID: "1",
//            content: .textField(textFieldComponentContent),
//            titleText: "Title text",
//            detailTitle: "Detail title",
//            detailText: "This is the detail text",
//            promptPrefix: nil,
//            required: true)),
//        textFieldComponentContent: textFieldComponentContent
//    )
//    .background(Colors.background)
//    
//}
