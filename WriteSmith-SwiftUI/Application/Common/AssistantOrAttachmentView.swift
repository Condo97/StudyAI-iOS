//
//  AssistantOrAttachmentView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/24/24.
//

import SwiftUI

struct AssistantOrAttachmentView: View {
    
    var assistant: Assistant?
    var persistentAttachment: PersistentAttachment?
    
    @Environment(\.colorScheme) private var colorScheme
    
//    private let faceFrameDiameter: CGFloat = 76.0
    
    var body: some View {
        if let persistentAttachment = persistentAttachment {
            AttachmentView(persistentAttachment: persistentAttachment)
        } else if let assistant = assistant {
            AssistantView(assistant: assistant)
//                .frame(width: 72.0, height: 72.0)
        } else {
            FaceAnimationResizableView.worm(color: UIColor(Colors.elementBackgroundColor))
        }
    }
    
}

//#Preview {
//    AssistantOrAttachmentView()
//}
