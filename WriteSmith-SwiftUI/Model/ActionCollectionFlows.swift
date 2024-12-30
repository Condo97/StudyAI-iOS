//
//  ActionCollectionFlows.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/22/24.
//

import Foundation

enum ActionCollectionFlows {
    
    case essay
    
}

extension ActionCollectionFlows {
    
    var actionCollectionFlowType: ActionCollectionFlowProtocol.Type {
        switch self {
        case .essay: EssayActionCollectionFlowView.self
        }
    }
    
}
