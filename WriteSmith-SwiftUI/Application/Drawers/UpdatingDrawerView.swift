//
//  UpdatingDrawerView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/18/24.
//

import CoreData
import Foundation
import SwiftUI

struct UpdatingDrawerView: View {
    
    @State var drawer: GeneratedDrawer
    @State var additionalPromptForRegeneration: String
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var drawerHeaderText: String
    @State private var drawerContentText: String
    
    init(drawer: GeneratedDrawer, additionalPromptForRegeneration: String) {
        self._drawer = State(initialValue: drawer)
        self._drawerHeaderText = State(initialValue: drawer.header ?? drawer.headerOriginal ?? "")
        self._drawerContentText = State(initialValue: drawer.content ?? drawer.contentOriginal ?? "")
        self._additionalPromptForRegeneration = State(initialValue: additionalPromptForRegeneration)
    }
    
    var body: some View {
        DrawerView(
            drawerHeaderText: $drawerHeaderText,
            drawerBodyText: $drawerContentText,
            additionalPromptForRegeneration: additionalPromptForRegeneration)
        .onChange(of: drawerHeaderText) { newValue in
            // Update drawer header text in CoreData
            do {
                try viewContext.performAndWait {
                    drawer.header = newValue
                    
                    try viewContext.save()
                }
            } catch {
                // TODO: Handle Errors
                print("Error saving viewContext in UpdatingDrawerView... \(error)")
            }
        }
        .onChange(of: drawerContentText) { newValue in
            // Update drawer body text in CoreData
            do {
                try viewContext.performAndWait {
                    drawer.content = newValue
                    
                    try viewContext.save()
                }
            } catch {
                // TODO: Handle Errors
                print("Error saving viewContext in UpdatingDrawerView... \(error)")
            }
        }
    }
    
}
