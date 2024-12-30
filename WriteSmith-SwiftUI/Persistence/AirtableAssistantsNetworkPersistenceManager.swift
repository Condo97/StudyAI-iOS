//
//  AirtableAssistantsNetworkPersistenceManager.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/12/24.
//

import CoreData
import Foundation

class AirtableAssistantsNetworkPersistenceManager {
    
    static func getUpdateCreateAndSaveAllAssistants(in managedContext: NSManagedObjectContext) async throws {
        // Create ListAssistantsRequest
        let listAssistantsRequest = ListAssistantsRequest(
            offset: nil
        )
        
        // Get and save all assistants with listAssistantsRequest
        try await getAndSaveAllAssistants(listAssistantsRequest: listAssistantsRequest, in: managedContext)
    }
    
    private static func getAndSaveAllAssistants(listAssistantsRequest: ListAssistantsRequest, in managedContext: NSManagedObjectContext) async throws {
        // TODO: Add a "updateNecessary" attribute or computed value that makes the assistant get updated or deleted somehow ? Is that necessary?
        // Get listAssistantsResponse with listAssistantsRequest, otherwise return
        let listAssistantsResponse = try await AirtableConnector.listAssistants(listAssistantsRequest: listAssistantsRequest)
        
        // Ensure records can be unwrapped, otherwise return
        guard var records = listAssistantsResponse.records else  {
            // TODO: Handle Errors
            print("Could not unwrap records in WebAssistantsNetworkPersistenceManager! Returning...")
            return
        }
        
        // Get AirtableAssistants from CoreData
        let allAirtableAssistants = try await AirtableAssistantsCDHelper.getAll(in: managedContext)
        
        // Map records to two arrays, one where airtableID == CoreData airtableID && updateEpochTime > CoreData updateEpochTime, the other where airtableID is not contained in any CoreData airtableAssistant
        let toUpdateRecords: [ListAssistantsResponse.Record] = records.filter({ record in
            allAirtableAssistants.contains(where: { airtableAssistant in
                record.id == airtableAssistant.airtableID && (record.fields?.updateEpochTime != nil && record.fields!.updateEpochTime! > airtableAssistant.updateEpochTime)
            })
        })
        let toInsertRecords: [ListAssistantsResponse.Record] = records.filter({ record in
            !allAirtableAssistants.contains(where: { airtableAssistant in
                record.id == airtableAssistant.airtableID
            })
        })
        
        // Update assistants for toUpdateRecords
        try await managedContext.perform {
            for toUpdateRecord in toUpdateRecords {
                // Unwrap responseAssistant from toUpdateRecord, otherwise continue
                guard let responseAssistant = toUpdateRecord.fields else {
                    // Could not unwrap responseAssistant from toUpdateRecord, continuing
                    print("Could not unwrap responseAssistant from toUpdateRecord, continuing!")
                    continue
                }
                
                // Get and unwrap airtableAssistant from allAirtableAssistants where its airtableID equals toUpdateRecord's id, otherwise continue
                guard let airtableAssistant = allAirtableAssistants.first(where: { $0.airtableID == toUpdateRecord.id }) else {
                    // No assistant found for toUpdateRecord airtableID, continuing
                    print("No assistnat found for toUpdateRecord airtableID, continuing!")
                    continue
                }
                
                // Set assistant values from responseAssistant
                airtableAssistant.assistant?.assistantDescription = responseAssistant.shortDescription
                airtableAssistant.assistant?.assistantShortDescription = responseAssistant.subtitle
                airtableAssistant.assistant?.category = responseAssistant.category
                airtableAssistant.assistant?.deviceCreated = false
                airtableAssistant.assistant?.displayBackgroundColorName = nil
                airtableAssistant.assistant?.emoji = responseAssistant.emoji
                airtableAssistant.assistant?.faceStyleID = nil
                airtableAssistant.assistant?.featured = false
                airtableAssistant.assistant?.imagePath = nil // TODO: Save image to device from url
                airtableAssistant.assistant?.initialMessage = responseAssistant.initialMessage
                airtableAssistant.assistant?.name = responseAssistant.name
                airtableAssistant.assistant?.premium = true
                airtableAssistant.assistant?.pronouns = nil
                airtableAssistant.assistant?.systemPrompt = responseAssistant.systemPrompt
                airtableAssistant.assistant?.usageMessages = responseAssistant.usageMessages ?? -1
                airtableAssistant.assistant?.usageUsers = responseAssistant.usageUsers ?? -1
                airtableAssistant.assistant?.userCreated = false
                
                // Set airtableAssistant updateEpochTime
                airtableAssistant.updateEpochTime = responseAssistant.updateEpochTime ?? -1
            }
            
            // Save to CoreData
            try managedContext.save()
        }
        
        // Insert assistants for toInsertRecords
        try await managedContext.perform {
            for toInsertRecord in toInsertRecords {
                // Unwrap responseAssistant from toUpdateRecord, otherwise continue
                guard let responseAssistant = toInsertRecord.fields else {
                    // Could not unwrap responseAssistant from toUpdateRecord, continuing
                    print("Could not unwrap responseAssistant from toUpdateRecord, continuing!")
                    continue
                }
                
                // Create Assistant
                let assistant = Assistant(context: managedContext)
                assistant.assistantDescription = responseAssistant.shortDescription
                assistant.assistantShortDescription = responseAssistant.subtitle
                assistant.category = responseAssistant.category
                assistant.deviceCreated = false
                assistant.displayBackgroundColorName = nil
                assistant.emoji = responseAssistant.emoji
                assistant.faceStyleID = nil
                assistant.featured = false
                assistant.imagePath = nil // TODO: Save image to device from url
                assistant.initialMessage = responseAssistant.initialMessage
                assistant.name = responseAssistant.name
                assistant.premium = true
                assistant.pronouns = nil
                assistant.systemPrompt = responseAssistant.systemPrompt
                assistant.usageMessages = responseAssistant.usageMessages ?? -1
                assistant.usageUsers = responseAssistant.usageUsers ?? -1
                assistant.userCreated = false
                
                // Create AirtableAssistant and associate Assistant
                let airtableAssistant = AirtableAssistant(context: managedContext)
                airtableAssistant.airtableID = toInsertRecord.id
                airtableAssistant.updateEpochTime = responseAssistant.updateEpochTime ?? -1
                airtableAssistant.assistant = assistant
            }
            
            // Save to CoreData
            try managedContext.save()
        }
        
        
        
//        // Create WebAssistants for each assistant in response
//        for record in records {
//            // Ensure responseAssistant can be unwrapped, otherwise continue
//            guard let responseAssistant = record.fields else {
//                // TODO: Handle Errors if Necessary
//                print("Could not unwrap responseAssistant in WebAssistantsNetworkPersistenceManager! Continuing to parse records..")
//                continue
//            }
//            
//            // Ensure record id can be unwrapped as airtableID, otherwise continue
//            guard let airtableID = record.id else {
//                // TODO: Handle Errors if Necessary
//                print("Could not unwrap record id in WebAssistantsNetworkPersistenceManager! Continuing to parse records..")
//                continue
//            }
//            
//            // Get AirtableAssistants for airtableID and if the array is not nil and has more than one object delete all objects and save and insert and associate AirtableAssistant and Assistant and set assistant to Assistant and if the array has one object get its Assistant and set to assistant, otherwise if nil or empty insert and associate AirtableAssistant and Assistant and set assistant to Assistant
////            let airtableAssistantsForAirtableID: [WebAssistant]?
//            let assistant: Assistant
//            do {
//                assistant = try await getOrCreateAssistantWithAirtableAssistant(
//                    airtableID: airtableID,
//                    in: managedContext)
//            } catch {
//                // TODO: Handle Errors if Necessary
//                print("Error getting or creating assistant with airtable assistant in AirtableAssistantsPersistenceManager, continuing to parse records... \(error)")
//                continue
//            }
//            
//            try await managedContext.perform {
//                // Set assistant values from responseAssistant
//                assistant.assistantDescription = responseAssistant.shortDescription
//                assistant.assistantShortDescription = responseAssistant.subtitle
//                assistant.category = responseAssistant.category
//                assistant.deviceCreated = false
//                assistant.displayBackgroundColorName = nil
//                assistant.emoji = responseAssistant.emoji
//                assistant.faceStyleName = nil
//                assistant.featured = false
//                assistant.imagePath = nil // TODO: Save image to device from url
//                assistant.initialMessage = responseAssistant.initialMessage
//                assistant.name = responseAssistant.name
//                assistant.premium = true
//                assistant.pronouns = nil
//                assistant.systemPrompt = responseAssistant.systemPrompt
//                assistant.usageMessages = responseAssistant.usageMessages ?? -1
//                assistant.usageUsers = responseAssistant.usageUsers ?? -1
//                assistant.userCreated = false
//                
//                // Save to CoreData
//                try managedContext.save()
//            }
//        }
//        
//        // If offset can be unwrapped, call getAndSaveAllAssistants again with listAssistantsRequest including the offset
//        if let offset = listAssistantsResponse.offset {
//            // Create newAssistantsRequest
//            let newListAssistantsRequest = ListAssistantsRequest(
//                offset: offset
//            )
//            
//            // Call getAndSaveAllAssistants with newListAssistantsRequest
//            try await getAndSaveAllAssistants(
//                listAssistantsRequest: newListAssistantsRequest,
//                in: managedContext)
//        }
    }
    
    
//    private static func getOrCreateAssistantWithAirtableAssistant(airtableID: String, in managedContext: NSManagedObjectContext) async throws -> Assistant {
//        var assistant: Assistant?
//        do {
//            let airtableAssistantsForAirtableID = try await AirtableAssistantsCDHelper.get(
//                for: airtableID,
//                in: managedContext)
//            
//            if let airtableAssistantsForAirtableID = airtableAssistantsForAirtableID, airtableAssistantsForAirtableID.count == 1 {
//                // Fetch Assistant from first and only object of airtableAssistantsForAirtableID
//                let fetchRequest = Assistant.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Assistant.airtable), airtableAssistantsForAirtableID[0])
//                
//                assistant = await managedContext.perform { [fetchRequest] in
//                    // Get the first object from the fetchRequest, otherwise return nil TODO: Delete other Assistants associated with the AssistantID here too I guess lol
//                    do {
//                        let fetchedAssistants = try managedContext.fetch(fetchRequest)
//                        
//                        if fetchedAssistants.count == 1 {
//                            // If fetchedAssistants has one object, return it
//                            return fetchedAssistants[0]
//                        } else if fetchedAssistants.count > 1 {
//                            // If fetchedAssistants count is greater than one, delete all fetchedAssistants and their assistants, and return nil
//                            for fetchedAssistant in fetchedAssistants {
//                                managedContext.delete(fetchedAssistant)
//                            }
//                            
//                            for airtableAssistant in airtableAssistantsForAirtableID {
//                                managedContext.delete(airtableAssistant)
//                            }
//                            
//                            try managedContext.save()
//                            
//                            return nil
//                        } else {
//                            // If fetchedResults count is zero, return nil
//                            return nil
//                        }
//                    } catch {
//                        // TODO: Handle Errors if Necessary
//                        print("Error fetching assistant in AirtableAssistantsPersistenceManager... \(error)")
//                        return nil
//                    }
//                }
//            } else if let airtableAssistantsForAirtableID = airtableAssistantsForAirtableID, airtableAssistantsForAirtableID.count > 1 {
//                // Delete Assistants and AirtableAssistants
//                for airtableAssistant in airtableAssistantsForAirtableID {
//                    do {
//                        try await AirtableAssistantsCDHelper.deleteAirtableAssistantAndAssistant(
//                            airtableAssistant: airtableAssistant,
//                            in: managedContext)
//                    } catch {
//                        // TODO: Handle Errors if Necessary
//                        print("Error deleting airtable assistant and assistant in AirtableAssistantPersistenceManager... \(error)")
//                    }
//                }
//            }
//            
//            // Unwrap assistant and return it, otherwise create and return airtableAssistant and assistant
//            if let assistant = assistant {
//                // If assistant can be unwrapped, return it
//                return assistant
//            } else {
//                return try await managedContext.perform {
//                    // If assistant is nil, create and associate and save a new AirtableAssistant and Assistant and return it
//                    let airtableAssistant = AirtableAssistant(context: managedContext)
//                    airtableAssistant.airtableID = airtableID
//                
//                // This should throw through becuase it's the final attempt to insert an Assistant and AirtableAssistant and this function cannot return nil
//                    try managedContext.save()
//                
//                    let insertedAssistant = Assistant(context: managedContext)
//                    insertedAssistant.airtable = airtableAssistant
//                    
//                    // Save and if there was an error try to delete the airtableAssistant and save again
//                    do {
//                        try managedContext.save()
//                    } catch {
//                        // TODO: Handle Errors if Necessary
//                        print("Error saving managedContext in AirtableAssistantPersistenceManager... \(error)")
//                        throw error
//                    }
//                    
//                    return insertedAssistant
//                }
//                
//            }
//        }
//    }
    
}
