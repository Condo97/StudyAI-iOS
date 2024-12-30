//
//  ConversationRow.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/12/23.
//

import FaceAnimation
import Foundation
import SwiftUI

struct ConversationRow: View {
    
    @State var conversation: Conversation
    @State var action: ()->Void
    @FetchRequest var persistentAttachments: FetchedResults<PersistentAttachment>
    
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    private static let faceDiameter: CGFloat = 48.0
    private static let faceFrame: CGRect = CGRect(x: 0, y: 0, width: faceDiameter, height: faceDiameter)
    private static let facialFeaturesScaleFactor: CGFloat = 0.76
    private static let faceColor: UIColor = UIColor(Colors.elementBackgroundColor)
    private static let faceStartAnimation: FaceAnimation = FaceAnimationRepository.center(duration: 0.0)
    private let circleInnerPadding: CGFloat = 0.0
    
    var customDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }
    
    var formattedLatestChatDate: String? {
        guard let latestChatDate = conversation.latestChatDate else {
            return nil
        }
        
        return customDateFormatter.string(from: latestChatDate)
    }
    
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12.0) {
                ZStack {
                    rowIcon
//                    if let staticFaceAssistantImage = conversation.assistant?.faceStyle?.staticImageName {
//                        Image(staticFaceAssistantImage)
//                            .resizable()
//                    } else if let uiImage = conversation.assistant?.uiImage {
//                        Image(uiImage: uiImage)
//                            .resizable()
//                    } else if let emoji = conversation.assistant?.emoji {
//                        Text(emoji)
//                            .font(.custom(Constants.FontName.body, size: 28.0))
//                    } else {
//                        Image(FaceStyles.man.staticImageName)
//                            .resizable()
//                    }
                }
                .frame(width: ConversationRow.faceDiameter, height: ConversationRow.faceDiameter)
                .aspectRatio(contentMode: .fill)
                .foregroundStyle(Colors.text)
//                .padding(4)
//                .background(
//                    ZStack {
//                        Colors.background
//                        
//                        ZStack {
//                            if let displayBackgroundColorName = conversation.assistant?.displayBackgroundColorName {
//                                Color(displayBackgroundColorName)
//                            } else {
//                                Colors.foreground
//                            }
//                        }
//                        .opacity(0.6)
//                    }
//                )
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                
                VStack(alignment: .leading) {
                    // Conversation Title
                    Text(
                        conversation.actionCollection?.title
                        ??
                        conversation.latestChatText
                        ??
                        "No Chat..."
                    )
                    .font(.custom(conversation.latestChatText == nil ? Constants.FontName.bodyOblique : Constants.FontName.body, size: 17.0))
                    .lineLimit(1)
                    
                    // Conversation Formatted Date
                    Text(
                        formattedLatestChatDate
                        ??
                        (conversation.actionCollection?.date != nil ? customDateFormatter.string(from: conversation.actionCollection!.date!) : nil)
                        ??
                        "Unknown"
                    )
                    .font(.custom(Constants.FontName.heavy, size: 12.0))
                    .opacity(0.4)
                    .lineLimit(1)
                }
                
                Spacer()
                
                if let conversationToResume = try? ConversationResumingManager.getConversation(in: viewContext), conversationToResume == conversation {
                    // Conversation to resume image
                    Text(Image(systemName: "rectangle.and.pencil.and.ellipsis"))
                        .font(.custom(Constants.FontName.body, size: 20.0))
                        .opacity(0.4)
                }
                
                Image(systemName: "chevron.right")
                    .font(.custom(Constants.FontName.body, size: 20.0))
            }
        }
        .foregroundStyle(Colors.text)
//        .padding(4)
        .listRowBackground(Colors.foreground)
    }
    
    var rowIcon: some View {
        ZStack {
            // TODO: ActionCollection icon?
            if let persistentAttachment = persistentAttachments.first,
               let attachmentTypeString = persistentAttachment.attachmentType,
               let attachmentType = AttachmentType(rawValue: attachmentTypeString) {
                // Attachment
                switch attachmentType {
                case .flashcards:
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .imageScale(.large)
                        .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        .padding()
                case .image:
                    if let attachmentFilePath = persistentAttachment.documentsFilePath,
                       let uiImage = try? DocumentSaver.getImage(from: attachmentFilePath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
//                            .frame(height: rowIconDiame)
                    } else {
                        // TODO: Show Default Image
                    }
                case .pdfOrText:
                    Image(systemName: "doc.text")
                        .imageScale(.large)
                        .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        .padding()
                case .voice:
                    Image(systemName: "waveform")
                        .imageScale(.large)
                        .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        .padding()
                case .webUrl:
                    Image(systemName: "link")
                        .imageScale(.large)
                        .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        .padding()
                }
            } else if let assistant = conversation.assistant {
                // Assistant
                if let staticFaceAssistantImage = assistant.faceStyle?.staticImageName {
                    // Static face
                    Image(staticFaceAssistantImage)
                        .resizable()
                } else if let uiImage = assistant.uiImage {
                    // Image
                    Image(uiImage: uiImage)
                        .resizable()
                } else if let emoji = assistant.emoji {
                    //
                    Text(emoji)
                        .font(.custom(Constants.FontName.body, size: 28.0))
                } else {
                    Image(FaceStyles.man.staticImageName)
                        .resizable()
                }
            }
        }
    }
    
}


//#Preview {
//    
//    let fetchRequest = Conversation.fetchRequest()
//    
//    var conversation: Conversation?
//    CDClient.mainManagedObjectContext.performAndWait {
//        let results = try? CDClient.mainManagedObjectContext.fetch(fetchRequest)
//        
//        conversation = results![safe: 0]
//    }
//    
//    return ConversationRow(
//        conversation: conversation!,
//        action: {
//            
//        },
//        persistentAttachments: FetchRequest(
//            sortDescriptors: [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)],
//            predicate: NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), conversation!)))
//    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
//    
//}
