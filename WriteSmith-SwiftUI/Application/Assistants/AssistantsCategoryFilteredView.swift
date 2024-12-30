//
//  AssistantsCategoryFilteredView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/28/24.
//

import CoreData
import Foundation
import SwiftUI

struct AssistantsCategoryFilteredView: View {
    
    @State var category: AssistantCategories
    @Binding var selectedAssistant: Assistant?
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)],
//        predicate: NSPredicate, animation: <#T##Animation?#>)
    @FetchRequest private var filteredAssistants: FetchedResults<Assistant>
    
    @State private var isShowingUltraView: Bool = false
    
    @State private var presentingAssistant: Assistant?
    var isPresentingAssistant: Binding<Bool> {
        Binding(
            get: {
                presentingAssistant != nil
            },
            set: { value in
                if !value {
                    presentingAssistant = nil
                }
            })
    }
    @State private var presentingAssistantConfirmedForUse: Bool = false
    
    
    init(category: State<AssistantCategories>, selectedAssistant: Binding<Assistant?>) {
        self._category = category
        self._selectedAssistant = selectedAssistant
        
        self._filteredAssistants = FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Assistant.usageMessages), ascending: false)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Assistant.category), category.wrappedValue.rawValue),
            animation: .default)
    }
    
    var body: some View {
//        NavigationStack {
            ZStack {
                ScrollView {
                    HStack {
                        Text(category.rawValue)
                            .font(.custom(Constants.FontName.heavy, size: 24.0))
                        
                        Spacer()
                    }
                    
                    VStack {
                        ForEach(filteredAssistants) { assistant in
                            Button(action: {
                                self.presentingAssistant = assistant
                            }) {
                                VStack {
                                    HStack(spacing: 16.0) {
                                        let emojiBackgroundColor: Color? = {
                                            if let displayBackgroundColorName = assistant.displayBackgroundColorName,
                                               let uiColor = UIColor(named: displayBackgroundColorName) {
                                                return Color(uiColor)
                                            }
                                            
                                            return nil
                                        }()
                                        
                                        ZStack {
                                            if let uiImage = assistant.uiImage {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                            } else if let emoji = assistant.emoji {
                                                Text(emoji)
                                                    .font(.custom(Constants.FontName.body, size: 28.0))
                                                    .padding(4)
                                            }
                                        }
                                        .frame(width: 40.0, height: 40.0)
                                        .aspectRatio(contentMode: .fill)
                                        .background(
                                            ZStack {
                                                Colors.background
                                                
                                                ZStack {
                                                    emojiBackgroundColor ?? Colors.foreground
                                                }
                                                .opacity(0.6)
                                            }
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                                        
                                        VStack(alignment: .leading) {
                                            if let name = assistant.name {
                                                Text(name)
                                                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                                                    .multilineTextAlignment(.leading)
                                            }
                                            
                                            if let category = assistant.category {
                                                Text(category)
                                                    .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
                                                    .opacity(0.6)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(Image(systemName: "chevron.right"))
                                            .font(.custom(Constants.FontName.body, size: 14.0))
                                            .opacity(0.6)
                                    }
                                    .foregroundStyle(Colors.text)
                                    .padding([.top, .bottom], 8)
                                }
                            }
                        }
                    }
                    .padding(8)
                    .padding([.leading, .trailing], 8)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
            }
            .ultraViewPopover(isPresented: $isShowingUltraView)
            .navigationDestination(isPresented: isPresentingAssistant) {
                if presentingAssistant != nil {
                    AssistantDetailView(
                        assistant: presentingAssistant.unsafelyUnwrapped,
                        setAssistantConfirmed: $presentingAssistantConfirmedForUse)
                    .onChange(of: presentingAssistantConfirmedForUse) { newValue in
                        // Set presentingAssistantConfirmedForUse to false to allow for selection again
                        presentingAssistantConfirmedForUse = false
                        
                        // Ensure presentingAssistant is not premium or is premium and user is premium, otherwise show ultra view and return
                        guard let presentingAssistant = presentingAssistant, !presentingAssistant.premium || presentingAssistant.premium && premiumUpdater.isPremium else {
                            isShowingUltraView = true
                            return
                        }
                        
                        // Set SelectedAssistant
                        self.selectedAssistant = presentingAssistant
                        
                        // Set presentingAssistant to nil
                        self.presentingAssistant = nil
                    }
                }
            }
//        }
//        .onChange(of: presentingAssistantConfirmedForUse) { newValue in
//            // Set presentingAssistantConfirmedForUse to false to allow for selection again
//            presentingAssistantConfirmedForUse = false
//            
//            // Ensure presentingAssistant is not premium or is premium and user is premium, otherwise show ultra view and return
//            guard let presentingAssistant = presentingAssistant, !presentingAssistant.premium || presentingAssistant.premium && premiumUpdater.isPremium else {
//                isShowingUltraView = true
//                return
//            }
//            
//            // Set SelectedAssistant
//            self.selectedAssistant = presentingAssistant
//        }
    }
    
}


//@available(iOS 17.0, *)
//#Preview {
//    
//    AssistantsCategoryFilteredView(
//        category: State(initialValue: .stem),
//        selectedAssistant: .constant(nil))
//        .background(Colors.background)
//        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
