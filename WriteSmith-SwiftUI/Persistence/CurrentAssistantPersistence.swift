//
//  CurrentAssistantPersistence.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/26/24.
//

import CoreData
import Foundation

class CurrentAssistantPersistence {
    
    static func getAssistant(in managedContext: NSManagedObjectContext) throws -> Assistant? {
        // If everything can be unwrapped and everything is successful return conversation, otherwise return nil
        if let assistantObjectIDURIRepresentation = getAssistantObjectIDURLRepresentation(),
           let assistantObjectID = managedContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: assistantObjectIDURIRepresentation),
           let assistant = try managedContext.existingObject(with: assistantObjectID) as? Assistant {
           return assistant
        }
        
        return nil
    }
    
    private static func getAssistantObjectIDURLRepresentation() -> URL? {
        UserDefaults.standard.url(forKey: Constants.UserDefaults.userDefaultStoredActiveAssistant)
    }
    
    static func setAssistant(_ assistant: Assistant, in managedContext: NSManagedObjectContext) throws {
        // Obtain permanent ID and set conversation to its URI representation
        try managedContext.obtainPermanentIDs(for: [assistant])
        setAssistantObjectIDURLRepresentation(assistant.objectID.uriRepresentation())
    }
    
    private static func setAssistantObjectIDURLRepresentation(_ assistantObjectIDURLRepresentationToResume: URL) {
//            try? await ConversationCDHelper.convertToPermanentID(conversation)
        UserDefaults.standard.set(assistantObjectIDURLRepresentationToResume, forKey: Constants.UserDefaults.userDefaultStoredActiveAssistant)
    }
    
    static func setNil() {
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.userDefaultStoredActiveAssistant)
    }
    
}
