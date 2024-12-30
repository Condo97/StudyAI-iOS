////
////  FaceAssistants.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 3/28/24.
////
//
//import Foundation
//
//struct FaceAssistants {
//    
//    struct FaceAssistantSpec: Identifiable {
//        var id: Int
//        var name: String
//        var category: String
//        var description: String?
//        var systemPrompt: String?
//        var premium: Bool
//        
//        var faceStyle: FaceStyles?
//    }
//    
//    static var defaultFaceAssistant = FaceAssistantSpec(
//        id: 1,
//        name: "Prof. Write",
//        category: "All Purpose",
//        description: "I'm Professor Write, your source for research and writing help. Try asking me to do deep dives on topics. Just chat like I'm a human... I've been here a while!",
//        systemPrompt: "You are a male professor personality.",
//        premium: false,
//        faceStyle: FaceStyles.original)
//    
//    static var faceAssistants: [FaceAssistantSpec] = [
//        // Male
//        defaultFaceAssistant,
//        
//        // Female
//        FaceAssistantSpec(
//            id: 2,
//            name: "WandAI",
//            category: "All Purpose",
//            description: "Hi I'm NAME, your friendly AI assistant. Ask me anything you'd like to know, how to do tasks, and more. I'm here to help!",
//            premium: false,
//            faceStyle: FaceStyles.artist),
//        
//        // Neutral
//        FaceAssistantSpec(
//            id: 3,
//            name: "Named",
//            category: "All Purpose",
//            premium: false,
//            faceStyle: FaceStyles.genius),
//        
//        // Artist
//        FaceAssistantSpec(
//            id: 4,
//            name: "Artist",
//            category: "Art",
//            description: "Just ask me to create art and I'll make it for you!",
//            systemPrompt: "You are a young female artist and give art advice.",
//            premium: true,
//            faceStyle: FaceStyles.original),
//        
//        // Bookworm
//        FaceAssistantSpec(
//            id: 5,
//            name: "Bookworm",
//            category: "Writing",
//            premium: true,
//            faceStyle: FaceStyles.artist),
//        
//        // Designer
//        FaceAssistantSpec(
//            id: 6,
//            name: "Designer",
//            category: "Creative & Design",
//            description: "Send a pic and I'll give you fashion advice, help you with your makeup, and even give your room feng shui.",
//            systemPrompt: "You are a designer and design advisor. If you don't know what you are designing, ask the user what they want to design.",
//            premium: true,
//            faceStyle: FaceStyles.genius)
//    ]
//    
//}
