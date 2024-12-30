//
//  PanelComponentViewProtocol.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/26/23.
//

import SwiftUI

protocol PanelComponentViewProtocol: View {
    associatedtype T: PanelComponentProtocol
    
    var component: T { get set }
    
//    var finalizedPrompt: String? { get set }
//    var input: String { get set }
    
}
