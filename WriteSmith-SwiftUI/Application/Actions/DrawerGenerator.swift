//
//  DrawerGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/19/24.
//

import CoreData
import Foundation
import SwiftUI

class DrawerGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    
    
    func generateDrawerCollection(text: String, imageData: Data?, authToken: String, in managedContext: NSManagedObjectContext) async throws -> GeneratedDrawerCollection {
        /* isLoading Setup */
        
        // Ensure is not loading, otherwise return nil
        guard !isLoading else {
            // Throw currentlyLoading TODO: Is this a good way of handling errors?
            throw DrawerGeneratorError.currentlyLoading
        }
        
        // Defer setting isLoading to false to when the execution of this function completes
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // Set isLoading to true
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        /* Get from Server */
        
        // Create GenerateDrawersRequest
        let gdRequest = GenerateDrawersRequest(
            authToken: authToken,
            input: text,
            imageData: imageData)
        
        // Get GenerateDrawersResponse from ChitChatHTTPSConnector
        let gdResponse = try await ChitChatHTTPSConnector.generateDrawers(request: gdRequest)
        
        /* Save in CoreData */
        
        // Craete drawerCollection with GeneratedDrawerCollectionCDHelper
        let drawerCollection = try await GeneratedDrawerCollectionCDHelper.create(
            title: gdResponse.body.title,
            in: managedContext)
        
        // Create drawer for each drawer in gdResponse with GeneratedDrawerCDHelper
        for responseDrawer in gdResponse.body.drawers {
            let drawer = try await GeneratedDrawerCDHelper.create(
                index: responseDrawer.index,
                header: responseDrawer.title,
                content: responseDrawer.content,
                to: drawerCollection,
                in: managedContext)
        }
        
        // Return drawerCollection
        return drawerCollection
    }
    
}
