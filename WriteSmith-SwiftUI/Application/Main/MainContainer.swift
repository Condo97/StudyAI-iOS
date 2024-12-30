//
//  MainContainer.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/20/24.
//

import FaceAnimation
import SwiftUI

struct MainContainer: View {
    
    @State var panelGroups: [PanelGroup]?
    
    @State private var presentingConversation: Conversation?
    @State private var faceAssistant: Assistant?
    @State private var isLoadingExtensionAttachment: Bool = false
    
    init(panelGroups: [PanelGroup]?) {
        self._panelGroups = State(initialValue: panelGroups)
        
        /* Presenting Conversation Setup */
        
        // Set faceAssistant
        do {
            self._faceAssistant = State(initialValue: try CurrentAssistantPersistence.getAssistant(in: CDClient.mainManagedObjectContext))
        } catch {
            // TODO: Handle Errors
            print("Error getting assistant from CurrentAssistantPersistence in MainView... \(error)")
        }
        
        // Set presentingConversation
        self._presentingConversation = State(initialValue: {
            // If resume conversation on launch attempt to set conversation to conversationToResume
            if UserDefaults.standard.bool(forKey: Constants.UserDefaults.resumeConversationOnLaunch) {
                // Return conversation from ConversationResumingManager if not nil and successful
                do {
                    if let conversationToResume = try ConversationResumingManager.getConversation(in: CDClient.mainManagedObjectContext) {
                        return conversationToResume
                    }
                } catch {
                    // TODO: Handle Errors if Necessary
                    print("Error getting resumed Conversation at launch in MainView, continuing... \(error)")
                }
            }
            
            // Get most recent conversation by latestChatDate
            let conversationFetchRequest = Conversation.fetchRequest()
            conversationFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Conversation.latestChatDate, ascending: false)]
            conversationFetchRequest.fetchLimit = 1
            do {
                let mostRecentConversation = try CDClient.mainManagedObjectContext.performAndWait {
                    try CDClient.mainManagedObjectContext.fetch(conversationFetchRequest)[safe: 0]
                }
                
                // If mostRecentConversation can be unwrapped continue to get chats and check if there are one or none and return it
                if let mostRecentConversation = mostRecentConversation {
                    let chatsFetchRequest = Chat.fetchRequest()
                    chatsFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Chat.conversation), mostRecentConversation)
                    chatsFetchRequest.fetchLimit = 2
                    do {
                        let mostRecentChats = try CDClient.mainManagedObjectContext.performAndWait {
                            try CDClient.mainManagedObjectContext.fetch(chatsFetchRequest)
                        }
                        
                        if mostRecentChats.count <= 1 {
                            return mostRecentConversation
                        }
                    } catch {
                        // TODO: Handle Errors if Necessary
                        print("Error getting Chats from most recent Conversation in MainView, continuing... \(error)")
                    }
                }
            } catch {
                // TODO: Handle Errors if Necessary
                print("Error getting most recent Conversation in MainView, continuing... \(error)")
            }
            
            // Create conversation and add initial chat, otherwise if an error is encountered return nil TODO: Is it a good idea to add initial chat here, since this is creating a new conversation on launch and therefore won't call the update to conversation automatically or whatever so it seems like it's fine adding it here
            do {
                let conversation = try ConversationCDHelper.appendConversation(
                    modelID: PremiumUpdater.get() ? GPTModels.gpt4o.rawValue : GPTModels.gpt4oMini.rawValue,
                    assistant: faceAssistant,// ?? ,
                    in: CDClient.mainManagedObjectContext)
                
                return conversation
            } catch {
                // TODO: Handle Errors if Necessary
                print("Error creating Conversation at launch in MainView... \(error)")
                return nil
            }
        }())
        if let presentingConversation = presentingConversation {
            do {
                try ConversationResumingManager.setConversation(presentingConversation, in: CDClient.mainManagedObjectContext)
            } catch {
                // TODO: Handle Errors
                print("Error setting Conversation in ConversationResumingManager in MainView... \(error)")
            }
        }
    }
    
    var body: some View {
        MainView(
            faceAssistant: $faceAssistant,
            panelGroups: $panelGroups,
            presentingConversation: $presentingConversation)
        .clearFullScreenCover(isPresented: $isLoadingExtensionAttachment) {
            // Is Loading Extension Attachment View
            ZStack {
                Colors.foreground
                    .opacity(0.6)
                VStack {
                    FaceAnimationResizableView(
//                                frame: AssistantsView.faceFrame,
                        eyesImageName: FaceStyles.worm.eyesImageName,
                        mouthImageName: FaceStyles.worm.mouthImageName,
                        noseImageName: FaceStyles.worm.noseImageName,
                        faceImageName: FaceStyles.worm.backgroundImageName,
                        facialFeaturesScaleFactor: 0.76, // TODO: Make this a constant
                        eyesPositionFactor: FaceStyles.worm.eyesPositionFactor,
                        faceRenderingMode: FaceStyles.worm.faceRenderingMode,
                        color: .blue,
                        startAnimation: FaceAnimationRepository.center(duration: 0.0))
                    .frame(width: 120.0, height: 120.0)
                    .offset(y: 1)
                    Text("Loading Attachment")
                    ProgressView()
                }
            }
            .ignoresSafeArea()
        }
        .onOpenURL(perform: { url in
            Task {
                if url.absoluteString == "studyai://sharedata" {
                    checkForSharedData()
                }
            }
        })
    }
    
    func checkForSharedData(triesLeft: Int = 5) {
        guard triesLeft > 0 else {
            return
        }
        
        let fileLoader = AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID)

        if let sharedData = fileLoader.loadCodable(SharedData.self, from: "sharedData.json") {
            Task {
                await processSharedData(sharedData)
                fileLoader.deleteFile(named: "sharedData.json")
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                checkForSharedData(triesLeft: triesLeft - 1)
            })
        }
    }
    
    func processSharedData(_ sharedData: SharedData) async {
        // Defer setting isLoadingExtensionAttachment to false
        defer {
            DispatchQueue.main.async { isLoadingExtensionAttachment = false }
        }
        
        // Set isLoadingExtensionAttachment to true
        await MainActor.run {
            isLoadingExtensionAttachment = true
        }
        
        var persistentAttachment: PersistentAttachment?
        
        if let urlString = sharedData.url,
           let url = URL(string: urlString) {
            do {
                persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createWebsiteAttachmentUpdateCachedTextAndGeneratedTitle(
                    externalURL: url,
                    in: CDClient.mainManagedObjectContext)
            } catch {
                // TODO: Handle Errors
                print("Error creating PersistentAttachment in WriteSmith_SwiftUIApp... \(error)")
                return
            }
        }
        
        if let text = sharedData.text {
            // TODO: Implement
        }
        
        if let imageAppGroupFilepath = sharedData.imageAppGroupFilepath {
            if let imageData = AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID)
                .loadData(from: imageAppGroupFilepath) {
                let imageDocumentsFilepath = UUID().uuidString
                
                do {
                    try DocumentSaver.save(imageData, to: imageDocumentsFilepath)
                } catch {
                    // TODO: Handle Errors
                    print("Error saving image to DocumentSaver in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
                
                do {
                    persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
                        type: .image,
                        documentsFilePath: imageDocumentsFilepath,
                        in: CDClient.mainManagedObjectContext)
                } catch {
                    // TODO: Handle Errros
                    print("Error creating PersistentAttachment in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
            }
            
        }
        
        if let voiceAppGroupFilepath = sharedData.voiceAppGroupFilepath {
            if let voiceData = AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID)
                .loadData(from: voiceAppGroupFilepath) {
                let voiceDocumentsFilepath = UUID().uuidString
                
                do {
                    try DocumentSaver.save(voiceData, to: voiceDocumentsFilepath)
                } catch {
                    // TODO: Handle Errors
                    print("Error saving voice to DocumentSaver in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
                
                do {
                    persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
                        type: .voice,
                        documentsFilePath: voiceDocumentsFilepath,
                        in: CDClient.mainManagedObjectContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error creating PersistentAttachment in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
            }
        }
        
        if let pdfAppGroupFilepath = sharedData.pdfAppGroupFilepath {
            if let pdfData = AppGroupLoader(appGroupIdentifier: Constants.Additional.appGroupID)
                .loadData(from: pdfAppGroupFilepath) {
                let pdfDocumentsFilepath = UUID().uuidString
                
                do {
                    try DocumentSaver.save(pdfData, to: pdfDocumentsFilepath)
                } catch {
                    // TODO: Handle Errors
                    print("Error saving voice to DocumentSaver in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
                
                do {
                    persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
                        type: .pdfOrText,
                        documentsFilePath: pdfDocumentsFilepath,
                        in: CDClient.mainManagedObjectContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error creating PersistentAttachment in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
            }
        }
        
        // Ensure unwrap persistentAttachment, otherwise return
        guard let persistentAttachment = persistentAttachment else {
            // TODO: Handle Errors
            print("Could not unwrap persistentAttachment in WirteSmith_SwiftUIApp!")
            return
        }
        
        // Create Conversation
        let conversation: Conversation
        do {
            conversation = try await ConversationCDHelper.appendConversation(
                modelID: GPTModelHelper.currentChatModel.rawValue,
                assistant: faceAssistant,
                in: CDClient.mainManagedObjectContext)
        } catch {
            // TODO: Handle Errors
            print("Error creating Conversation in WriteSmith_SwiftUIApp... \(error)")
            return
        }
        
        // Update persistentAttachment with conversation
        do {
            try await PersistentAttachmentCDHelper.update(persistentAttachment, conversation: conversation, in: CDClient.mainManagedObjectContext)
        } catch {
            // TODO: Handle Errros
            print("Error updating persistentAttachment with Conversation... \(error)")
            return
        }
        
        // Remove Assistant text from behavior
        do {
            try await ConversationCDHelper.removeAssistantTextFromBehavior(
                for: conversation,
                in: CDClient.mainManagedObjectContext)
        } catch {
            // TODO: Handle Errors
            print("Error removing Assistnat text from behavior... \(error)")
        }
        
        // Set presentingConversation to conversation
        await MainActor.run {
            presentingConversation = conversation
        }
    }
    
//    func processImportedFile(url: URL) async {
//        // Get attachment type from url
//        let attachmentType = AttachmentType.from(url: url)
//        
//        // Process per attachment type
//        await processAttachment(
//            attachmentType: attachmentType,
//            url: url)
//    }
//    
//    func processAttachment(attachmentType: AttachmentType, url: URL) async {
//        // Defer setting isLoadingExtensionAttachment to false
//        defer {
//            DispatchQueue.main.async { isLoadingExtensionAttachment = false }
//        }
//        
//        // Set isLoadingExtensionAttachment to true
//        await MainActor.run {
//            isLoadingExtensionAttachment = true
//        }
//        
//        var persistentAttachment: PersistentAttachment?
//        
//        switch attachmentType {
//        case .flashcards:
//            break
//        case .image:
//            let imageData: Data
//            do {
//                imageData = try Data(contentsOf: url, options: .alwaysMapped)
//            } catch {
//                // TODO: Handle Errors
//                print("Error getting imageData in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//            
//            let imageDocumentsFilepath = UUID().uuidString
//            
//            do {
//                try DocumentSaver.save(imageData, to: imageDocumentsFilepath)
//            } catch {
//                // TODO: Handle Errors
//                print("Error saving voice to DocumentSaver in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//            
//            do {
//                persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
//                    type: .image,
//                    documentsFilePath: imageDocumentsFilepath,
//                    in: CDClient.mainManagedObjectContext)
//            } catch {
//                // TODO: Handle Errros
//                print("Error creating PersistentAttachment in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//        case .pdfOrText:
//            let pdfData: Data
//            do {
//                pdfData = try Data(contentsOf: url, options: .alwaysMapped)
//            } catch {
//                // TODO: Handle Errors
//                print("Error getting imageData in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//            
//            let pdfDocumentsFilepath = UUID().uuidString
//            
//            do {
//                try DocumentSaver.save(pdfData, to: pdfDocumentsFilepath)
//            } catch {
//                // TODO: Handle Errors
//                print("Error saving voice to DocumentSaver in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//            
//            do {
//                persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
//                    type: .pdfOrText,
//                    documentsFilePath: pdfDocumentsFilepath,
//                    in: CDClient.mainManagedObjectContext)
//            } catch {
//                // TODO: Handle Errros
//                print("Error creating PersistentAttachment in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//        case .voice:
//            let voiceData: Data
//            do {
//                voiceData = try Data(contentsOf: url, options: .alwaysMapped)
//            } catch {
//                // TODO: Handle Errors
//                print("Error getting imageData in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//            
//            let voiceDocumentsFilepath = UUID().uuidString
//            
//            do {
//                try DocumentSaver.save(voiceData, to: voiceDocumentsFilepath)
//            } catch {
//                // TODO: Handle Errors
//                print("Error saving voice to DocumentSaver in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//            
//            do {
//                persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createUpdateCachedTextAndGeneratedTitle(
//                    type: .voice,
//                    documentsFilePath: voiceDocumentsFilepath,
//                    in: CDClient.mainManagedObjectContext)
//            } catch {
//                // TODO: Handle Errros
//                print("Error creating PersistentAttachment in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//        case .webUrl:
//            do {
//                persistentAttachment = try await PersistentAttachmentNetworkedPersistenceManager.createWebsiteAttachmentUpdateCachedTextAndGeneratedTitle(
//                    externalURL: url,
//                    in: CDClient.mainManagedObjectContext)
//            } catch {
//                // TODO: Handle Errors
//                print("Error creating PersistentAttachment in WriteSmith_SwiftUIApp... \(error)")
//                return
//            }
//        }
//        
//        // Ensure unwrap persistentAttachment, otherwise return
//        guard let persistentAttachment = persistentAttachment else {
//            // TODO: Handle Errors
//            print("Could not unwrap persistentAttachment in WirteSmith_SwiftUIApp!")
//            return
//        }
//        
//        // Create Conversation
//        let conversation: Conversation
//        do {
//            conversation = try await ConversationCDHelper.appendConversation(
//                modelID: GPTModelHelper.currentChatModel.rawValue,
//                assistant: faceAssistant,
//                in: CDClient.mainManagedObjectContext)
//        } catch {
//            // TODO: Handle Errors
//            print("Error creating Conversation in WriteSmith_SwiftUIApp... \(error)")
//            return
//        }
//        
//        // Update persistentAttachment with conversation
//        do {
//            try await PersistentAttachmentCDHelper.update(persistentAttachment, conversation: conversation, in: CDClient.mainManagedObjectContext)
//        } catch {
//            // TODO: Handle Errros
//            print("Error updating persistentAttachment with Conversation... \(error)")
//            return
//        }
//        
//        // Remove Assistant text from behavior
//        do {
//            try await ConversationCDHelper.removeAssistantTextFromBehavior(
//                for: conversation,
//                in: CDClient.mainManagedObjectContext)
//        } catch {
//            // TODO: Handle Errors
//            print("Error removing Assistnat text from behavior... \(error)")
//        }
//        
//        // Set presentingConversation to conversation
//        await MainActor.run {
//            presentingConversation = conversation
//        }
//    }
    
}

//#Preview {
//    
//    MainContainer()
//
//}
