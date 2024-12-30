//
//  AirtableAssistantsCDHelper.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/12/24.
//

import CoreData
import Foundation

class AirtableAssistantsCDHelper {
    
    static func getAll(in managedContext: NSManagedObjectContext) async throws -> [AirtableAssistant] {
        let fetchRequest = AirtableAssistant.fetchRequest()
        
        return try await managedContext.perform {
            return try managedContext.fetch(fetchRequest)
        }
    }
    
    static func get(for airtableID: String, in managedContext: NSManagedObjectContext) async throws -> [AirtableAssistant] {
        let fetchRequest = AirtableAssistant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(AirtableAssistant.airtableID), airtableID)
        
        return try await managedContext.perform {
            return try managedContext.fetch(fetchRequest)
        }
    }
    
    static func deleteAirtableAssistantAndAssistant(for airtableID: String, in managedContext: NSManagedObjectContext) async throws {
        let airtableAssistantsFetchRequest = AirtableAssistant.fetchRequest()
        airtableAssistantsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(AirtableAssistant.airtableID), airtableID)
        
        let airtableAssistants = try await managedContext.perform {
            return try managedContext.fetch(airtableAssistantsFetchRequest)
        }
        
        for airtableAssistant in airtableAssistants {
            try await deleteAirtableAssistantAndAssistant(
                airtableAssistant: airtableAssistant,
                in: managedContext)
        }
    }
    
    static func deleteAirtableAssistantAndAssistant(airtableAssistant: AirtableAssistant, in managedContext: NSManagedObjectContext) async throws {
        let fetchRequest = Assistant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Assistant.airtable), airtableAssistant)
        
        try await managedContext.perform {
            for result in try managedContext.fetch(fetchRequest) {
                managedContext.delete(result)
            }
            
            managedContext.delete(airtableAssistant)
            
            try managedContext.save()
        }
    }
    
}
