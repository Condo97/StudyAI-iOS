////
////  FaceAssistantUpdater.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 3/28/24.
////
//
//import Foundation
//import SwiftUI
//
//class FaceAssistantUpdater: ObservableObject {
//    
//    @Published var assistantSpec: FaceAssistants.FaceAssistantSpec?
//    
//    private var faceAssistantUserDefaults: FaceAssistants.FaceAssistantSpec {
//        get {
//            let userDefaultsFaceAssistantID = UserDefaults.standard.integer(forKey: Constants.UserDefaults.userDefaultStoredFaceAssistantID)
//            
//            return FaceAssistants.faceAssistants.first(where: {$0.id == userDefaultsFaceAssistantID}) ?? FaceAssistants.defaultFaceAssistant
//        }
//        set {
//            UserDefaults.standard.setValue(newValue, forKey: Constants.UserDefaults.userDefaultStoredFaceAssistantID)
//        }
//    }
//    
//    init() {
//        // Get the assistantSpec from User Defaults
//        assistantSpec = faceAssistantUserDefaults
//    }
//    
//    func setAssistant(id: Int) {
//        if let faceAssistant = FaceAssistants.faceAssistants.first(where: {$0.id == id}) {
//            self.assistantSpec = faceAssistant
//        }
//    }
//    
//}
