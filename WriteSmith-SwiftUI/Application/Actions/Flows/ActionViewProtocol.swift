//
//  ActionViewProtocol.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/21/24.
//

import Foundation

protocol ActionViewProtocol {
    var action: Action { get set }
    var onGenerate: (String) async -> Void { get set }
}
