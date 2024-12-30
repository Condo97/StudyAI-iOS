//
//  RemoveButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/3/24.
//

import Foundation
import SwiftUI

struct RemoveButton: View {
    
    var remove: () -> Void
    
    
    enum RemoveButtonStates {
        case deselected
        case toConfirm
    }
    
    @Namespace private var namespace
    
    @State private var removeButtonMatchedGeometryEffectID: String = "removeButtons"
    
    @State private var buttonState: RemoveButtonStates = .deselected
    
    var body: some View {
        Button(action: {
            switch buttonState {
            case .deselected:
                // Set button state to toConfirm
                withAnimation {
                    buttonState = .toConfirm
                }
            case .toConfirm:
                // Remove and set buttonState to deselected
                remove()
                
                withAnimation {
                    buttonState = .deselected
                }
            }
        }) {
            if buttonState == .deselected {
                Image(systemName: "minus")
                    .imageScale(.medium)
                    .matchedGeometryEffect(id: removeButtonMatchedGeometryEffectID, in: namespace)
                    .padding([.top, .bottom], 8)
            } else if buttonState == .toConfirm {
                Text("Delete")
                    .font(.custom(Constants.FontName.heavy, size: 14.0))
                    .matchedGeometryEffect(id: removeButtonMatchedGeometryEffectID, in: namespace)
            }
        }
        .padding(4)
        .foregroundStyle(Colors.elementTextColor)
        .background(Color(uiColor: .systemRed))
        .clipShape(RoundedRectangle(cornerRadius: 28.0))
    }
    
}


//#Preview {
//    
//    RemoveButton(remove: {
//        
//    })
//    
//}
