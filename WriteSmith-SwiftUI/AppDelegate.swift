//
//  AppDelegate.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/24/24.
//

import Adjust
import AppsFlyerLib
import AppTrackingTransparency
import BranchSDK
import FacebookCore
import FirebaseCore
import Foundation
import SwiftUI
import TenjinSDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
//        // Configure Facebook
//        Settings.shared.isAdvertiserIDCollectionEnabled = true
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Configure Branch
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            print(params as? [String: AnyObject] ?? {})
            // Access and use deep link data here (nav to page, display content, etc.)
        }
        
        // Configure Adjust
        let yourAppToken = "fdb2sb4vtdkw"
        #if DEBUG
        let environment: String = ADJEnvironmentSandbox
        #else
        let environment: String = ADJEnvironmentProduction
        #endif
        let adjustConfig = ADJConfig(
            appToken: yourAppToken,
            environment: environment)
        
        adjustConfig?.logLevel = ADJLogLevelVerbose
        Adjust.appDidLaunch(adjustConfig)
        
        // Configure AppsFlyer
        AppsFlyerLib.shared().appsFlyerDevKey = "Vdj9XCjeq7Wpfd5Q2cXCUD"
        AppsFlyerLib.shared().appleAppID = "1664039953"
        
//        UIApplication.shared.registerForRemoteNotifications()
        
        // Migrate
        migrate()
        
        // Request push notifications, which will later request tracking
        Task {
              let center = UNUserNotificationCenter.current()
              try await center.requestAuthorization(options: [.badge, .sound, .alert])
            
              // 3
              await MainActor.run {
                application.registerForRemoteNotifications()
              }
            }
        
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Start AppsFlyer
        AppsFlyerLib.shared().start()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            do {
                let registerAPNSRequest = APNSRegistrationRequest(
                    authToken: try await AuthHelper.ensure(),
                    deviceID: deviceToken)
                
                let response = try await ChitChatHTTPSConnector.registerAPNS(request: registerAPNSRequest)
                
                // TODO: Handle Response
            } catch {
                // TODO: Handle Errors if Necessary
                print("Error registering APNS in AppDelegate... \(error)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            // Request Tracking Authorization
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Set Facebook Advertising Tracking Enabled to True
                Settings.shared.isAdvertiserTrackingEnabled = true
                Settings.shared.isAdvertiserIDCollectionEnabled = true
                
                // Connect Tenjin
                //                    DispatchQueue.main.async {
                TenjinSDK.getInstance("UN4PPH4ZU5Z3S6BDDJZZCXLPPFFJ5XLP", andSharedSecret: Keys.sharedSecret)
                TenjinSDK.connect()
                TenjinSDK.debugLogs()
                TenjinSDK.sendEvent(withName: "test_event")
                //                    }
            })
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            // Start Tenjin Stuff
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Set Facebook Advertising Tracking Enabled to True
                Settings.shared.isAdvertiserTrackingEnabled = true
                Settings.shared.isAdvertiserIDCollectionEnabled = true
                
                // Connect Tenjin
                //                    DispatchQueue.main.async {
                TenjinSDK.getInstance("UN4PPH4ZU5Z3S6BDDJZZCXLPPFFJ5XLP", andSharedSecret: Keys.sharedSecret)
                TenjinSDK.connect()
                TenjinSDK.debugLogs()
                TenjinSDK.sendEvent(withName: "test_event")
                //                    }
            })
        })
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Set notFirstLaunchEver to true
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.notFirstLaunchEver)
    }
    
    
    func migrate() {
        
        if !UserDefaults.standard.bool(forKey: Constants.Migration.userDefaultStoredV5_7MigrationComplete) {
            do {
                try V5_7MigrationHandler.migrate(in: CDClient.mainManagedObjectContext)
            } catch {
                // TODO: Handle Errors
                print("Error migrating to V5_7 in AppDelegate... \(error)")
            }
        }
        
    }
    
}
