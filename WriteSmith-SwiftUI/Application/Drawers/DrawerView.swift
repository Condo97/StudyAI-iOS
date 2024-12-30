//
//  DrawerView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import Foundation
import SwiftUI

struct DrawerView: View {
    
    @Binding var drawerHeaderText: String
    @Binding var drawerBodyText: String
    @State var additionalPromptForRegeneration: String
    
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    private static let defaultPromptPrefixForRegenerationText: String = "Generate the body based on the new header. Don't include the header or \"Content\" descriptor. A drawer contains Header and Content which is shown when tapped."
    private static let defaultPromptNewHeaderPrefixForRegenerationText: String = "New Header: "
    private static let defaultAdditionalPromptForRegenerationText: String = "Regenerate only the drawer's body. Don't include the header or \"Content\" descriptor. Provided is only one drawer's header and this is a regeneration request."
    
    
    @StateObject private var simpleChatGenerator: SimpleChatGenerator = SimpleChatGenerator()
    
    @State private var isExpanded: Bool = false
    @State private var isEditingHeaderText: Bool = false
    
    
    var body: some View {
        VStack {
            // Header
            Button(action: {
                // Expand or unexpand drawer
                withAnimation(.spring(duration: 0.2)) {
                    isExpanded.toggle()
                    isEditingHeaderText = false
                }
            }) {
                HStack {
                    // Header Text Button
                    Button(action: {
                        if isExpanded {
                            withAnimation(.spring(duration: 0.2)) {
                                isEditingHeaderText = true
                            }
                        } else {
                            isExpanded.toggle()
                        }
                    }) {
                        if isEditingHeaderText {
                            TextField("Tap to enter header...", text: $drawerHeaderText)
                                .font(.custom(Constants.FontName.body, size: 20.0))
                                .foregroundStyle(Colors.textOnBackgroundColor)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14.0)
                                        .stroke(Colors.text, lineWidth: 1.0)
                                        .opacity(0.1)
                                )
                        } else {
                            Text(drawerHeaderText)
                                .underline(isExpanded, color: Colors.buttonBackground)
                                .font(.custom(Constants.FontName.body, size: 20.0))
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(Colors.textOnBackgroundColor)
                        }
                        
                        if isExpanded && !isEditingHeaderText {
                            Button(action: {
                                withAnimation(.spring(duration: 0.2)) {
                                    isEditingHeaderText = true
                                }
                            }) {
                                Text(Image(systemName: "pencil"))
                                    .font(.custom(Constants.FontName.body, size: 20.0))
                                    .foregroundStyle(Colors.buttonBackground)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Text(Image(systemName: "chevron.down"))
                        .font(.custom(Constants.FontName.body, size: 20.0))
                        .foregroundStyle(Colors.buttonBackground)
                }
            }
            
            // Body
            if isExpanded {
                Divider()
                    .frame(width: 280)
                    .opacity(0.6)
                
                VStack {
                    // Regenerate Button
                    if isEditingHeaderText {
                        HStack {
                            // Close button
                            Button(action: {
                                isEditingHeaderText = false
                            }) {
                                HStack {
                                    Spacer()
                                    
                                    Text("Close")
                                        .font(.custom(Constants.FontName.body, size: 17.0))
                                        .minimumScaleFactor(0.5)
                                    
                                    Spacer()
                                }
                                .foregroundStyle(Colors.buttonBackground)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14.0)
                                    .stroke(Colors.buttonBackground, lineWidth: 1.0))
                                //                                    .background(Colors.elementTextColor)
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                            }
                            
                            // Regenerate button
                            Button(action: {
                                Task {
                                    do {
                                        try await simpleChatGenerator.generate(
                                            input: DrawerView.defaultPromptPrefixForRegenerationText + "\n\n" + additionalPromptForRegeneration + "\n\n" + DrawerView.defaultPromptNewHeaderPrefixForRegenerationText + drawerHeaderText + "\n\n" + DrawerView.defaultAdditionalPromptForRegenerationText,
                                            image: nil,
                                            imageURL: nil,
                                            isPremium: premiumUpdater.isPremium)
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error generating update chat in DrawerView... \(error)")
                                    }
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    
                                    Text("Regenerate")
                                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                                        .minimumScaleFactor(0.5)
                                    
                                    Text(Image(systemName: "sparkles"))
                                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                                        .minimumScaleFactor(0.5)
                                    
                                    Spacer()
                                }
                                .foregroundStyle(Colors.elementTextColor)
                                .padding()
                                .background(Colors.buttonBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                
                                //                                Text(Image(systemName: "sparkles"))
                                //                                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                            }
                        }
                    }
                    
                    // Body field
                    HStack {
                        TextField("Tap to start typing...", text: $drawerBodyText, axis: .vertical) // TODO: Needs to be in its own subclass
                            .font(.custom(Constants.FontName.body, size: 14.0))
                            .disabled(simpleChatGenerator.isLoading || simpleChatGenerator.isGenerating) // Disable when loading or generating
                            .overlay {
                                if simpleChatGenerator.isLoading {
                                    ZStack {
                                        Colors.foreground
                                            .opacity(0.2)
                                        
                                        ProgressView()
                                            .tint(Colors.elementBackgroundColor)
                                    }
                                }
                            }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14.0)
                            .stroke(Colors.text, lineWidth: 1.0)
                            .opacity(0.1)
                    )
                }
            }
        }
        .onReceive(simpleChatGenerator.$generatedTexts) { newValue in
            // Set highest index generated to drawerBodyText if not empty TODO: Is this a good implementation?
            if !newValue.isEmpty {
                self.drawerBodyText = newValue.max(by: {$0.key < $1.key})?.value ?? ""
            }
        }
    }
    
}


//#Preview {
//    
//    DrawerView(
//        drawerHeaderText: .constant("Test Header Text"),
//        drawerBodyText: .constant("Test body text"),
//        additionalPromptForRegeneration: "Original prompt"
//    )
//}
