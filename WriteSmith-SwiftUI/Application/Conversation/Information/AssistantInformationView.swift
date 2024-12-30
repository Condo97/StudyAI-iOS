//
//  AssistantInformationView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/28/24.
//

import CoreData
import FaceAnimation
import Foundation
import SwiftUI

struct AssistantInformationView: View {
    
    @Binding var isPresented: Bool
    var conversation: Conversation
    
    
    enum ClearStates {
        case deselected
        case selectOnce
        case selectTwice
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    @Namespace private var namespace
    
    private let faceFrameDiameter: CGFloat = 128.0
    
    @State private var pronounsText: String = ""
    @State private var selectedPronouns: Pronouns?
    
    @State private var pronounsClearState: ClearStates = .deselected
    
    @State private var alertShowingEditCustomPronouns: Bool = false
    
    @State private var isDisplayingPronounsDisplay: Bool = false
    
    @State private var isToggledEnableTextFormatting: Bool = false
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16.0) {
                // Assistant Display
                assistantDisplay
                
                // Name
                if let name = conversation.assistant?.name {
                    Text(name)
                        .font(.custom(Constants.FontName.black, size: 28.0))
                        .foregroundStyle(Colors.textOnBackgroundColor)
                }
                
                // Description
                if let description = conversation.assistant?.assistantDescription {
                    Text(description)
                        .multilineTextAlignment(.center)
                        .font(.custom(Constants.FontName.body, size: 17.0))
                        .foregroundStyle(Colors.textOnBackgroundColor)
                }
                
                // Information View
                InformationView(
                    isPresented: $isPresented,
                    conversation: conversation)
                
//                // Pronouns Display
//                pronounsDisplay
                
                Spacer()
            }
            .padding([.top, .leading, .trailing]) // This is here to show the scroll indicators outside the padding
            .onAppear {
                // Set text formatting toggle to the opposite of conversation textFormattingDisabled
                isToggledEnableTextFormatting = !conversation.textFormattingDisabled
                
                // Set selectedpronouns and isDisplayingPronounsDisplay and pronounsText if selectedPronouns is custom
                if let pronouns = conversation.assistant?.pronouns {
                    self.selectedPronouns = Pronouns.from(name: pronouns)
                    
                    self.isDisplayingPronounsDisplay = true
                    
                    if self.selectedPronouns == .custom {
                        self.pronounsText = pronouns
                    }
                }
            }
            .alert("Custom Pronouns", isPresented: $alertShowingEditCustomPronouns, actions: {
                TextField("test", text: $pronounsText)
                    .foregroundStyle(.black)
                
                Button("Cancel", role: .cancel) {
                    
                }
                
                Button("Save") {
                    // Set assistant pronouns to pronounsText in CoreData
                    self.conversation.assistant?.pronouns = self.pronounsText
                    
                    do {
                        try viewContext.performAndWait {
                            try viewContext.save()
                        }
                    } catch {
                        // TODO: Handle Errors
                        print("Error saving viewContext in AssistantInformationView... \(error)")
                    }
                }
            }) {
                Text("Specify your custom pronouns")
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.isPresented = false
                    }) {
                        Text(Image(systemName: "chevron.down"))
                            .font(.custom(Constants.FontName.body, size: 24.0))
                    }
                    .padding(.trailing)
                    .foregroundStyle(Colors.buttonBackground)
                }
                
                Spacer()
            }
            .padding()
        }
        .alert("Custom Pronouns", isPresented: $alertShowingEditCustomPronouns, actions: {
            TextField("test", text: $pronounsText)
                .foregroundStyle(.black)
            
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Save") {
                // Set assistant pronouns to pronounsText in CoreData
                self.conversation.assistant?.pronouns = self.pronounsText
                
                do {
                    try viewContext.performAndWait {
                        try viewContext.save()
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error saving viewContext in AssistantInformationView... \(error)")
                }
            }
        }) {
            Text("Specify your custom pronouns")
        }
    }
    
    var assistantDisplay: some View {
        ZStack {
            if let faceStyle = conversation.assistant?.faceStyle {
                ZStack {
                    FaceAnimationResizableView(
//                        frame: CGRect(x: 0, y: 0, width: faceFrameDiameter, height: faceFrameDiameter),
                        eyesImageName: faceStyle.eyesImageName,
                        mouthImageName: faceStyle.mouthImageName,
                        noseImageName: faceStyle.noseImageName,
                        faceImageName: faceStyle.backgroundImageName,
                        facialFeaturesScaleFactor: 0.72,
                        eyesPositionFactor: faceStyle.eyesPositionFactor,
                        faceRenderingMode: faceStyle.faceRenderingMode,
                        color: UIColor(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor),
                        startAnimation: FaceAnimationRepository.center(duration: 0.0))
                    .frame(width: faceFrameDiameter, height: faceFrameDiameter)
                    .padding([.top, .bottom], -8)
                }
                .padding()
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            } else if let uiImage = conversation.assistant?.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: faceFrameDiameter)
            } else if let emoji = conversation.assistant?.emoji {
                Text(emoji)
                    .font(.custom(Constants.FontName.body, size: 68.0))
                    .frame(width: faceFrameDiameter, height: faceFrameDiameter)
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
            } else {
                Text("No Assistant")
            }
        }
    }
    
    var pronounsDisplay: some View {
        VStack(spacing: 8.0) {
            HStack {
                // Pronouns Header
                Text("Pronouns")
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                
                Spacer()
                
                // Clear Button
                if selectedPronouns != nil {
                    // Clear Button
                    Button(action: {
                        switch pronounsClearState {
                        case .deselected:
                            pronounsClearState = .selectOnce
                        case .selectOnce, .selectTwice:
                            pronounsClearState = .selectTwice
                            // Set assistant pronouns and selectedPronouns to nil and save in CoreData TODO: Working on this
                            self.conversation.assistant?.pronouns = nil
                            self.selectedPronouns = nil
                            
                            do {
                                try viewContext.performAndWait {
                                    try viewContext.save()
                                }
                            } catch {
                                // TODO: Handle Errors
                                print("Error saving viewContext in AssistantInformationView... \(error)")
                            }
                            
                            pronounsClearState = .deselected
                        }
                    }) {
                        Text(pronounsClearState == .deselected ? "Clear" : "Confirm")
                            .font(.custom(pronounsClearState == .deselected ? Constants.FontName.body : Constants.FontName.heavy, size: 17.0))
                    }
                    .foregroundStyle(Colors.buttonBackground)
                }
//                else {
//                    if !isDisplayingPronounsDisplay {
//                        // Show Button
//                        Button(action: {
//                            withAnimation {
//                                isDisplayingPronounsDisplay = true
//                            }
//                        }) {
//                            Text("Show \(Image(systemName: "chevron.down"))")
//                                .font(.custom(Constants.FontName.heavy, size: 17.0))
//                        }
//                        .foregroundStyle(Colors.buttonBackground)
//                    } else {
//                        // Hide Button
//                        Button(action: {
//                            withAnimation {
//                                isDisplayingPronounsDisplay = false
//                            }
//                        }) {
//                            Text("Hide \(Image(systemName: "chevron.up"))")
//                                .font(.custom(Constants.FontName.heavy, size: 17.0))
//                        }
//                        .foregroundStyle(Colors.buttonBackground)
//                    }
//                }
            }
            
            // Pronouns Display
            if isDisplayingPronounsDisplay {
                VStack {
                    HStack {
                        // He/Him Button
                        Button(action: {
                            // Set selectedPronouns to heHim
                            withAnimation {
                                self.selectedPronouns = .heHim
                            }
                            
                            // Set assistant pronouns in CoreData
                            self.conversation.assistant?.pronouns = self.selectedPronouns?.name
                            
                            do {
                                try viewContext.performAndWait {
                                    try viewContext.save()
                                }
                            } catch {
                                // TODO: Handle Errors
                                print("Error saving viewContext in AssistantInformationView... \(error)")
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text(Pronouns.heHim.name)
                                    .font(.custom(Constants.FontName.heavy, size: 14.0))
                                Spacer()
                            }
                        }
                        .padding([.top, .bottom], 8)
                        .padding(8)
                        .foregroundStyle(colorScheme == .dark ? (self.selectedPronouns == .heHim ? Colors.elementBackgroundColor : Colors.text) : (self.selectedPronouns == .heHim ? Colors.elementTextColor : Colors.text))
                        .background(
                            ZStack {
                                if self.selectedPronouns == .heHim {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                        .matchedGeometryEffect(id: "pronounsSelection", in: namespace)
                                }
                            }
                        )
                        
                        // She/Her Button
                        Button(action: {
                            // Set pronouns to sheHer
                            withAnimation {
                                self.selectedPronouns = .sheHer
                            }
                            
                            // Set assistant pronouns in CoreData
                            self.conversation.assistant?.pronouns = self.selectedPronouns?.name
                            
                            do {
                                try viewContext.performAndWait {
                                    try viewContext.save()
                                }
                            } catch {
                                // TODO: Handle Errors
                                print("Error saving viewContext in AssistantInformationView... \(error)")
                            }
                        }) {
                            HStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text(Pronouns.sheHer.name)
                                        .font(.custom(Constants.FontName.heavy, size: 14.0))
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        .padding([.top, .bottom], 8)
                        .padding(8)
                        .foregroundStyle(colorScheme == .dark ? (self.selectedPronouns == .sheHer ? Colors.elementBackgroundColor : Colors.text) : (self.selectedPronouns == .sheHer ? Colors.elementTextColor : Colors.text))
                        .background(
                            ZStack {
                                if self.selectedPronouns == .sheHer {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                        .matchedGeometryEffect(id: "pronounsSelection", in: namespace)
                                }
                            }
                        )
                    }
                    
                    HStack {
                        // They/Them Button
                        Button(action: {
                            // Set selectedPronouns to theyThem
                            withAnimation {
                                self.selectedPronouns = .theyThem
                            }
                            
                            // Set assistant pronouns in CoreData
                            self.conversation.assistant?.pronouns = self.selectedPronouns?.name
                            
                            do {
                                try viewContext.performAndWait {
                                    try viewContext.save()
                                }
                            } catch {
                                // TODO: Handle Errors
                                print("Error saving viewContext in AssistantInformationView... \(error)")
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text(Pronouns.theyThem.name)
                                    .font(.custom(Constants.FontName.heavy, size: 14.0))
                                Spacer()
                            }
                        }
                        .padding([.top, .bottom], 8)
                        .padding(8)
                        .foregroundStyle(colorScheme == .dark ? (self.selectedPronouns == .theyThem ? Colors.elementBackgroundColor : Colors.text) : (self.selectedPronouns == .theyThem ? Colors.elementTextColor : Colors.text))
                        .background(
                            ZStack {
                                if self.selectedPronouns == .theyThem {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                        .matchedGeometryEffect(id: "pronounsSelection", in: namespace)
                                }
                            }
                        )
                        
                        // Custom Button
                        Button(action: {
                            // Set pronouns to custom
                            withAnimation {
                                self.selectedPronouns = .custom
                            }
                            
                            // Set assistant pronouns in CoreData
                            self.conversation.assistant?.pronouns = self.selectedPronouns?.name
                            
                            do {
                                try viewContext.performAndWait {
                                    try viewContext.save()
                                }
                            } catch {
                                // TODO: Handle Errors
                                print("Error saving viewContext in AssistantInformationView... \(error)")
                            }
                        }) {
                            HStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack(spacing: 0.0) {
                                        Text(Pronouns.custom.name)
                                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                                        
                                        if self.selectedPronouns == .custom {
                                            Text(conversation.assistant?.pronouns ?? "")
                                                .font(.custom(Constants.FontName.bodyOblique, size: 10.0))
                                        }
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        .padding([.top, .bottom], self.selectedPronouns == .custom ? 0 : 8)
                        .padding(8)
                        .foregroundStyle(colorScheme == .dark ? (self.selectedPronouns == .custom ? Colors.elementBackgroundColor : Colors.text) : (self.selectedPronouns == .custom ? Colors.elementTextColor : Colors.text))
                        .background(
                            ZStack {
                                if self.selectedPronouns == .custom {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                                        .matchedGeometryEffect(id: "pronounsSelection", in: namespace)
                                }
                            }
                        )
                    }
                }
                .padding(4)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                
                if self.selectedPronouns == .custom, let assistant = conversation.assistant {
                    // Custom Pronouns header
                    HStack {
                        Text("Custom Pronouns")
                            .font(.custom(Constants.FontName.heavy, size: 17.0))
                        
                        Spacer()
                    }
                    
                    // Custom Pronouns edit button
                    Button(action: {
                        alertShowingEditCustomPronouns = true
                    }) {
                        VStack(alignment: .leading) {
                            ZStack {
                                HStack {
                                    if let pronouns = assistant.pronouns {
                                        Text(pronouns)
                                            .font(.custom(Constants.FontName.body, size: 14.0))
                                    } else {
                                        Text("Tap to Set Custom Pronouns")
                                            .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(VStack {
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    
                                    Text(Image(systemName: "pencil.line"))
                                }
                                .padding(8)
                            })
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        }
                        .foregroundStyle(Colors.text)
                    }
                }
            } else {
                Button(action: {
                    withAnimation {
                        isDisplayingPronounsDisplay = true
                    }
                }) {
                    ZStack {
                        HStack {
                            Spacer()
                            
                            Text("Tap to Set Pronouns")
                                .font(.custom(Constants.FontName.bodyOblique, size: 14.0))
                            
                            
                            Spacer()
                        }
                        .padding()
                        .background(VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                Text(Image(systemName: "pencil.line"))
                            }
                            .padding(8)
                        })
                    }
                }
                .foregroundStyle(Colors.text)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
            }
        }
    }
    
}

//#Preview {
//    
//    let fetchRequest = Conversation.fetchRequest()
//    
//    var conversation: Conversation?
//    CDClient.mainManagedObjectContext.performAndWait {
//        conversation = try? CDClient.mainManagedObjectContext.fetch(fetchRequest).last
//    }
//    
//    if let conversation = conversation {
//        return NavigationStack {
//            ZStack {
//                
//            }
//            .popover(isPresented: .constant(true)) {
//                AssistantInformationView(
//                    isPresented: .constant(true),
//                    conversation: conversation)
//                .background(Colors.background)
//            }
//        }
//        .background(Colors.background)
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//        .environmentObject(PremiumUpdater())
//        .environmentObject(ProductUpdater())
//    } else {
//        return ZStack {
//            Text("No Conversations Found...")
//        }
//    }
//    
//}
