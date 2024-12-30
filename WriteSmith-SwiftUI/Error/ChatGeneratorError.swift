//
//  ChatGeneratorError.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/24/23.
//

import Foundation

enum ChatGeneratorError: Error {
    
    case _unreadableErrorResponse
    case addUserChat
    case nothingFromServer
    case imageGenerationError // TODO: Is this too unviersal?
    case invalidAuthToken
    case stringAboveMaxLength
    
}
