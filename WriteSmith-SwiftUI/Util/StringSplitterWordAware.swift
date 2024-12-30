//
//  StringSplitterWordAware.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/4/24.
//

import Foundation

struct StringSplitterWordAware {
    
    static func splitStringWordAware(_ input: String) -> (String, String) {
        guard !input.isEmpty else {
            return ("", "")
        }

        let words = input.split(separator: " ")
        var firstHalfWords: [Substring] = []
        var secondHalfWords = words
        
        var currentIndex = 0
        var totalLength = input.count
        let midpoint = totalLength / 2
        
        // Iterate through the words, trying to get close to the midpoint
        // without going over it to keep the first part shorter.
        for (index, word) in words.enumerated() {
            let currentLength = firstHalfWords.reduce(0) { $0 + $1.count + 1 } + word.count // +1 for the space
            
            if currentLength <= midpoint {
                firstHalfWords.append(word)
                currentIndex = index
            } else {
                break
            }
        }
        
        secondHalfWords.removeFirst(currentIndex + 1) // +1 because slice indices are inclusive at the start
        
        // Joining the words back together to form the two parts.
        let firstPart = firstHalfWords.joined(separator: " ")
        let secondPart = secondHalfWords.joined(separator: " ")
        
        return (String(firstPart), String(secondPart))
    }
    
}
