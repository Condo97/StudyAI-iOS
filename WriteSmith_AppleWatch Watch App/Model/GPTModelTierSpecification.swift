//
//  GPTModelTierSpecification.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 6/12/23.
//

import Foundation

// MARK: This is a control function
struct GPTModelTierSpecification {
    
    static let defaultModel: GPTModels = .gpt4oMini
    
    static let freeModels: [GPTModels] = [
        .gpt4oMini
    ]
    
    static let paidModels: [GPTModels] = [
        .gpt4o
    ]
    
}
