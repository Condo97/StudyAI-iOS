////
////  ActiveAssistantUpdater.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 3/26/24.
////
//
//import CoreData
//import Foundation
//import SwiftUI
//
//class ActiveAssistantUpdater: ObservableObject {
//    
//    struct AssistantSpec {
//        var systemPrompt: String?
//        
//        var emoji: String?
//        var emojiBackgroundColor: UIColor?
//
//        var image: UIImage?
//        var faceStyle: FaceStyles?
//        
//        var chatCount: Int?
//    }
//    
//    @Published var assistantSpec: AssistantSpec?
//    
//    init(managedObjectContext: NSManagedObjectContext) {
//        // Get the assistantSpec from User Defaults
//        do {
//            if let assistant = try getCurrentAssistantFromUserDefaults(in: managedObjectContext) {
//                let emojiBackgroundColor: UIColor? = {
//                    if let displayBackgroundColorString = assistant.displayBackgroundColor {
//                       return ColorConverter.color(from: displayBackgroundColorString)
//                    }
//                    
//                    return nil
//                }()
//                
//                DispatchQueue.main.async {
//                    self.assistantSpec = AssistantSpec(
//                        systemPrompt: assistant.systemPrompt,
//                        emoji: assistant.emoji,
//                        emojiBackgroundColor: emojiBackgroundColor,
//                        image: assistant.uiImage,
//                        faceStyle: assistant.faceStyle)
//                }
//                
//                Task {
//                    do {
//                        self.assistantSpec?.chatCount = try await AssistantCDHelper.countChats(for: assistant, in: managedObjectContext)
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error counting Chats in ActiveAssistantUpdater... \(error)")
//                    }
//                }
//            }
//        } catch {
//            print("Error getting current assistant in ActiveAssistantUpdater... \(error)")
//        }
//    }
//    
//    func setAssistant(_ assistant: Assistant, in managedObjectContext: NSManagedObjectContext) throws {
//        try setCurrentAssistantInUserDefaults(assistant, in: managedObjectContext)
//        
//        let emojiBackgroundColor: UIColor? = {
//            if let displayBackgroundColorString = assistant.displayBackgroundColor {
//               return ColorConverter.color(from: displayBackgroundColorString)
//            }
//            
//            return nil
//        }()
//        
//        DispatchQueue.main.async {
//            self.assistantSpec = AssistantSpec(
//                systemPrompt: assistant.systemPrompt,
//                emoji: assistant.emoji,
//                emojiBackgroundColor: emojiBackgroundColor,
//                image: assistant.uiImage,
//                faceStyle: assistant.faceStyle)
//        }
//        
//        Task {
//            do {
//                self.assistantSpec?.chatCount = try await AssistantCDHelper.countChats(for: assistant, in: managedObjectContext)
//            } catch {
//                // TODO: Handle Errors
//                print("Error counting Chats in ActiveAssistantUpdater... \(error)")
//            }
//        }
//    }
//    
//    
//    private func getCurrentAssistantFromUserDefaults(in managedContext: NSManagedObjectContext) throws -> Assistant? {
//        // If everything can be unwrapped and everything is successful return conversation, otherwise return nil
//        if let assistantObjectIDURIRepresentation = getAssistantObjectIDURLRepresentation(),
//           let assistantObjectID = managedContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: assistantObjectIDURIRepresentation),
//           let assistant = try managedContext.existingObject(with: assistantObjectID) as? Assistant {
//           return assistant
//        }
//        
//        return nil
//    }
//    
//    private func getAssistantObjectIDURLRepresentation() -> URL? {
//        UserDefaults.standard.url(forKey: Constants.UserDefaults.userDefaultStoredActiveAssistant)
//    }
//    
//    private func setCurrentAssistantInUserDefaults(_ assistant: Assistant, in managedContext: NSManagedObjectContext) throws {
//        // Obtain permanent ID and set conversation to its URI representation
//        try managedContext.obtainPermanentIDs(for: [assistant])
//        setAssistantObjectIDURLRepresentation(assistant.objectID.uriRepresentation())
//    }
//    
//    private func setAssistantObjectIDURLRepresentation(_ assistantObjectIDURLRepresentationToResume: URL) {
////            try? await ConversationCDHelper.convertToPermanentID(conversation)
//        UserDefaults.standard.set(assistantObjectIDURLRepresentationToResume, forKey: Constants.UserDefaults.userDefaultStoredActiveAssistant)
//    }
//    
//    private static func setNil() {
//        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.userDefaultStoredActiveAssistant)
//    }
//}
