//
//  ExploreMiniView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/2/24.
//

import SwiftUI

struct ExploreMiniView: View {
    
    var panelGroups: [PanelGroup]?
    @Binding var presentingPanel: Panel?
    
    private let panelSize = CGSize(width: 170.0, height: 120.0)
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                // Gets the first 3 panels
                let panelsMerged: [Panel] = {
                    var panelsMerged: [Panel] = []
                    
                    for i in 0..<3 {
                        if let panels = panelGroups?[safe: i]?.panels {
                            panelsMerged += panels
                        }
                    }
                    
                    return panelsMerged
                }()
                
                ForEach(panelsMerged) { panel in
                    KeyboardDismissingButton(action: {
                        // Do light haptic
                        HapticHelper.doLightHaptic()
                        
                        // Set presentingPanel to panel
                        presentingPanel = panel
                    }) {
                        PanelMiniView(panel: panel)
                    }
                    .foregroundStyle(Colors.text)
                    .frame(width: panelSize.width, height: panelSize.height)
                }
            }
            .padding([.leading, .trailing])
        }
        .scrollIndicators(.never)
    }
    
}

//#Preview {
//    
//    var panelGroups: [PanelGroup]? {
//        if let panelJson = PanelPersistenceManager.get() {
//            do {
//                return try PanelParser.parsePanelGroups(fromJson: panelJson)
//            } catch {
//                // TODO: Handle errors if necessary
//                print("Error parsing panel groups from panelJson in TabBar... \(error)")
//            }
//        }
//        
//        return nil
//    }
//    
//    return ExploreMiniView(
//        panelGroups: panelGroups,
//        presentingPanel: .constant(nil)
//    )
//    
//}
