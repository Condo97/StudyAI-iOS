//
//  WriteSmith_SwiftUIApp.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/20/23.
//

import AppTrackingTransparency
import BranchSDK
import GoogleMobileAds
import FaceAnimation
import FirebaseAnalytics
import SwiftUI
import TenjinSDK

@main
struct WriteSmith_SwiftUIApp: App {
    
    @StateObject private var constantsUpdater: ConstantsUpdater = ConstantsUpdater()
    @StateObject private var premiumUpdater: PremiumUpdater = PremiumUpdater()
    @StateObject private var productUpdater: ProductUpdater = ProductUpdater()
    @StateObject private var remainingUpdater: RemainingUpdater = RemainingUpdater()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    static let currentDeviceAssistantsVersion: Double = 562
    
//    @Environment(\.requestReview) private var requestReview
    
    @State private var alertShowingAppLaunchImportant: Bool = false
    
    @State private var isShowingIntroView: Bool
    @State private var isShowingUltraView: Bool = false
    
    @State private var presentingConversation: Conversation?
    @State private var faceAssistant: Assistant?
    
    private let firstTabBarViewEver: Bool
    
    private var panelGroups: [PanelGroup]? {
        if let panelJson = PanelPersistenceManager.get() {
            do {
                return try PanelParser.parsePanelGroups(fromJson: panelJson)
            } catch {
                // TODO: Handle errors if necessary
                print("Error parsing panel groups from panelJson in TabBar... \(error)")
            }
        }
        
        return nil
    }
    
    
    init() {
        print("HERE")
        // Set tint colors
        UIView.appearance().tintColor = UIColor(Colors.navigationItemColor)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Colors.buttonBackground)
        UIView.appearance(whenContainedInInstancesOf: [UIImagePickerController.self]).tintColor = UIColor(Colors.elementBackgroundColor)
        
        // Start Google Mobile Ads
        GADMobileAds.sharedInstance().start()
        
        // Show intro & set first tab bar view ever to not isIntroComplete
        self._isShowingIntroView = State(initialValue: !IntroManager.isIntroComplete)
        self.firstTabBarViewEver = !IntroManager.isIntroComplete
        
        // Start IAPManager transaction observer
        IAPManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingIntroView {
                    IntroPresenterView(isShowing: $isShowingIntroView)
                    .transition(.move(edge: .bottom))
                    .zIndex(1.0)
                } else {
                    MainContainer(panelGroups: panelGroups)
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            requestReview()
//                        }
//                    }
                    .onAppear {
                        if !firstTabBarViewEver && !premiumUpdater.isPremium {
//                            isShowingUltraView = true
                            
                            // Log sixth intro view and purchased_at_intro to true
                            Analytics.logEvent("intro_progression_v5.4", parameters: [
                                "view": 5 as NSObject
                            ])
                            
                            
                        } else if firstTabBarViewEver && !premiumUpdater.isPremium {
                            // Log purchased_at_intro as false
                            Analytics.logEvent("purchased_at_intro", parameters: [
                                "did_purchase": false as NSObject
                            ])
                            
                        } else if firstTabBarViewEver && premiumUpdater.isPremium {
                            // Log purchased_at_intro as true
                            Analytics.logEvent("purchased_at_intro", parameters: [
                                "did_purchase": true as NSObject
                            ])
                        }
                    }
                    .ultraViewPopover(isPresented: $isShowingUltraView)
                }
            }
            .onAppear {
                // Set isShowingUltraView out here so that it is not shown every time an ad is shown
                if !firstTabBarViewEver && !premiumUpdater.isPremium {
                    isShowingUltraView = true
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isShowingIntroView)
            .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
            .environmentObject(constantsUpdater)
            .environmentObject(premiumUpdater)
            .environmentObject(productUpdater)
            .environmentObject(remainingUpdater)
            .onAppear {
//                // Start Tenjin stuff
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    let center = UNUserNotificationCenter.current()
//                    center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
//                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                                //                    DispatchQueue.main.async {
//                                TenjinSDK.getInstance("UN4PPH4ZU5Z3S6BDDJZZCXLPPFFJ5XLP", andSharedSecret: Keys.sharedSecret)
//                                TenjinSDK.connect()
//                                TenjinSDK.debugLogs()
//                                TenjinSDK.sendEvent(withName: "test_event")
//                                //                    }
//                            })
//                        }
//                    })
//        //        }
//                }
            }
            .onAppear {
                ConstantsUpdater.setup(version: 1.0)
            }
            .onAppear {
                // Listen for storekit updates
                listenForStoreKitUpdates()
            }
            .onOpenURL(perform: { url in
                Branch.getInstance().handleDeepLink(url)
                
//                if url.absoluteString == "studyai://sharedata" {
//                    checkForSharedData()
//                }
            })
            .task {
                // Migrate as necessary
                await migrate()
            }
            .task(priority: .background) {
                // Update web assistants
                do {
                    try await AirtableAssistantsNetworkPersistenceManager.getUpdateCreateAndSaveAllAssistants(in: CDClient.mainManagedObjectContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error getting updating creating and saving all assistants in WriteSmith_SwiftUIApp... \(error)")
                }
            }
            .task(priority: .background) {
                
                /* Load Default Assistants */
                
                do {
//                    // If UserDefaults deviceAssistantsVersion is below app version delete device created assistants and load and update deviceAssistantsVersion
//                    if UserDefaults.standard.double(forKey: Constants.UserDefaults.deviceAssistantsVersion) < WriteSmith_SwiftUIApp.currentDeviceAssistantsVersion {
//                        // Delete device created assistants
//                        try await DefaultAssistantsCoreDataLoader.deleteDeviceCreatedAssistantsInCoreData(in: CDClient.mainManagedObjectContext)
//                        
//                        // Set deviceAssistantsVersion to currentDeviceAssistantsVersion
//                        UserDefaults.standard.set(WriteSmith_SwiftUIApp.currentDeviceAssistantsVersion, forKey: Constants.UserDefaults.deviceAssistantsVersion)
//                    }
                    
                    // TODO: Version handling
                    if try await !DefaultAssistantsCoreDataLoader.deviceCreatedAssistantExists(in: CDClient.mainManagedObjectContext) {
                        try await DefaultAssistantsCoreDataLoader.loadDefaultAssistantsInCoreData(in: CDClient.mainManagedObjectContext)
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error loading or checking default assistants in CoreData... \(error)")
                }
                
                /* Set Worm As Default Assistant */
                
                // Fetch Worm Assistant from Featured Assistant fetch request
                let wormFetchRequest = Assistant.fetchRequest()
                wormFetchRequest.predicate = NSPredicate(format: "%K = %d", #keyPath(Assistant.featured), true)
                
                let wormAssistant: Assistant?
                do {
                    wormAssistant = try await CDClient.mainManagedObjectContext.perform {
                        try CDClient.mainManagedObjectContext.fetch(wormFetchRequest).first(where: {$0.faceStyle?.id == FaceStyles.worm.id})
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error getting worm assistant in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
                
                // Unwrap wormAssistant, otherwise return
                guard let wormAssistant = wormAssistant else {
                    // TODO: Handle errors if necessary
                    print("Error unwrapping wormAssistant in WriteSmith_SwiftUIApp!")
                    return
                }
                
                // If no conversations, insert initial conversation
                let conversationCount: Int
                do {
                    conversationCount = try await ConversationCDHelper.countConversations(in: CDClient.mainManagedObjectContext)
                } catch {
                    // TODO: Handle Errors if Necessary
                    print("Error counting conversations in WriteSmith_SwiftUIApp... \(error)")
                    conversationCount = 0
                }
                
                // If no conversations or wormSetAsPrimaryAssistantForPreviousNonWormUsers is false
                if conversationCount == 0 || !UserDefaults.standard.bool(forKey: Constants.UserDefaults.wormSetAsPrimaryAssistantForPreviousNonWormUsers) {
                    // Set worm as current Assistant in CurrentAssistantPersistence
                    do {
                        try CurrentAssistantPersistence.setAssistant(wormAssistant, in: CDClient.mainManagedObjectContext)
                    } catch {
                        // TODO: Handle Errors
                        print("Error setting Assistant to CurrentAssistantPersistence in WriteSmith_SwiftUIApp... \(error)")
                    }
                    
                    // Set wormSetAsPrimaryAssistantForPreviousNonWormUsers to true in UserDefaults
                    UserDefaults.standard.set(true, forKey: Constants.UserDefaults.wormSetAsPrimaryAssistantForPreviousNonWormUsers)
                }
                
//                if conversationCount == 0 {
//                    // Create Conversation with selectedAssistant and set in ConversationResumingManager
//                    do {
//                        let conversation = try await ConversationCDHelper.appendConversation(
//                            modelID: GPTModels.gpt4oMini.rawValue,
//                            assistant: wormAssistant,
//                            in: CDClient.mainManagedObjectContext)
//                        
//                        do {
//                            try ConversationResumingManager.setConversation(conversation, in: CDClient.mainManagedObjectContext)
//                        } catch {
//                            // TODO: Handle Errors
//                            print("Error setting Conversation to ConversationResumingManager in WriteSmith_SwiftUIApp... \(error)")
//                        }
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error appending Conversation in WriteSmith_SwiftUIApp... \(error)")
//                    }
//                }
                    
            }
            .task {
                // Update important constants and then refresh productUpdater
                do {
                    try await ConstantsUpdater.update()
                    
                    await productUpdater.refresh()
                } catch {
                    // TODO: Handle errors
                    print("Error updating important constants in WriteSmith_SwiftUIApp... \(error)")
                }
                
                // Show alert if received from constants
                if let launchAlertText = ConstantsUpdater.appLaunchAlert {
                    alertShowingAppLaunchImportant = true
                }
            }
            .task {
                // Ensure authToken, then validate, otherwise return TODO: Handle errors
                let authToken: String
                do {
                    let tempAuthToken = try await AuthHelper.ensure()
                    
                    // TODO: Do this better
                    let authRequest = AuthRequest(authToken: tempAuthToken)
                    let statusResponse = try await ChitChatHTTPSConnector.validateAuthToken(request: authRequest)
                    if statusResponse.success == 5 {
                        try await AuthHelper.regenerate()
                    }
                    
                    authToken = try await AuthHelper.ensure()
                } catch {
                    // TODO: Handle errors
                    print("Error unwrapping authToken in WriteSmith_SwiftUIApp... \(error)")
                    return
                }
                
                // Update premium
                do {
                    try await premiumUpdater.update(authToken: authToken)
                } catch {
                    // TODO: Handle errors
                    print("Error updating premium in WriteSmith_SwiftUIApp... \(error)")
                }
                
                // Update remaining
                do {
                    try await remainingUpdater.update(authToken: authToken)
                } catch {
                    // TODO: Handle errors
                    print("Error updating remaining in WriteSmith_SwiftUIApp... \(error)")
                }
            }
            .alert("Issue Occurred", isPresented: $alertShowingAppLaunchImportant, actions: {
                Button("Done", role: .cancel, action: {
                    // Set appLaunchAlert to nil since it finished showing
                    ConstantsUpdater.appLaunchAlert = nil
                })
            }) {
                Text(ConstantsUpdater.appLaunchAlert ?? "There was an issue reaching one of our services. Please try again in a few moments.")
            }
        }
    }
    
    private func migrate() async {
        // TODO: This uses CDClient mainManagedObjectContext, is that fine?
        if !UserDefaults.standard.bool(forKey: Constants.Migration.userDefaultStoredV4MigrationComplete) {
            do {
                try await V4MigrationHandler.migrate(in: CDClient.mainManagedObjectContext)
            } catch {
                print("Error migrating to V4 in WriteSmith_SwiftUIApp... \(error)")
            }
            
            UserDefaults.standard.set(true, forKey: Constants.Migration.userDefaultStoredV4MigrationComplete)
        }
        
        // TODO: This uses CDClient mainManagedObjectContext, is that fine?
        if !UserDefaults.standard.bool(forKey: Constants.Migration.userDefaultStoredV4_2MigrationComplete) {
            do {
                try await V4_2MigrationHandler.migrate(in: CDClient.mainManagedObjectContext)
            } catch {
                print("Error migrating to V3_5 in WriteSmith_SwiftUIApp... \(error)")
            }
            
            UserDefaults.standard.set(true, forKey: Constants.Migration.userDefaultStoredV4_2MigrationComplete)
        }
    }
    
    func listenForStoreKitUpdates() {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    print("Transaction verified in listener")
                    
                    await transaction.finish()
                    
                    // Unwrap authToken
                    guard let authToken = try? await AuthHelper.ensure() else {
                        // TODO: Handle Errors
//                        // If the authToken is nil, show an error alert that the app can't connect to the server and return
//                        alertShowingErrorLoading = true
                        return
                    }
                    
                    // Register the transaction ID with the server
                    try await premiumUpdater.registerTransaction(authToken: authToken, transactionID: transaction.originalID)
                    
                    // Update the user's purchases...
                case .unverified:
                    print("Transaction unverified")
                }
            }
        }
    }
    
}
