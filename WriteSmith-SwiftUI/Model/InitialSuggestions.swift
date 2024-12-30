//
//  InitialSuggestions.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/4/24.
//

import Foundation

struct InitialSuggestions {
    
    static var initialSuggestions: [Suggestion] = [
//        Suggestion(
//            topPart: "Solve",
//            bottomPart: "Scan to solve",
//            prompt: "Explain and solve the given problem.",
//            requestsImageSend: true),
        
        Suggestion(
            topPart: "Math Scanner",
            bottomPart: "Solve math problem",
            prompt: "Explain and solve the given math problem.",
            requestsImageSend: true),
        
        Suggestion(
            topPart: "Chem Scanner",
            bottomPart: "Solve chem problem",
            prompt: "Explan and solve the given chem problem.",
            requestsImageSend: true),
        
        Suggestion(
            topPart: "Bio Scanner",
            bottomPart: "Solve bio problem",
            prompt: "Explan and solve the given chem problem.",
            requestsImageSend: true),
        
        Suggestion(
            topPart: "Summarize Page",
            bottomPart: "Capture text to summarize",
            prompt: "Summarize the given text.",
            requestsImageSend: true),
        
        Suggestion(
            topPart: "Scan Textbook",
            bottomPart: "Scan textbook cover or page",
            prompt: "Provide a summary of the given textbook or textbook page.",
            requestsImageSend: true),
        
        Suggestion(
            topPart: "Art Analysis",
            bottomPart: "AI analyzes your art",
            prompt: "Analyze the art that you receive. Provide a full artistic analysis.",
            requestsImageSend: true),
        
        Suggestion(
            topPart: "Visual Problem Solver",
            bottomPart: "Solves a visual problem",
            prompt: "Solve the problem from the given image.",
            requestsImageSend: true),
        
        
    ]
    
}
