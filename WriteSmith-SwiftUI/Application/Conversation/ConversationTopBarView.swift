//
//  ConversationTopBarView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/1/24.
//

import SwiftUI

struct ConversationTopBarView: View {
    
    @ObservedObject var conversation: Conversation
    @Binding var isShowingAssistantInformationView: Bool
    @Binding var isShowingAttachmentInformationView: Bool
    @FetchRequest var persistentAttachments: FetchedResults<PersistentAttachment>
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var premiumUpdater: PremiumUpdater
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                ZStack {
//                    let _ = Self._printChanges()
                    let assistant = conversation.assistant
                    let attachment = persistentAttachments.first
                    
                    Button(action: {
                        if attachment != nil {
                            self.isShowingAttachmentInformationView = true
                        } else {
                            self.isShowingAssistantInformationView = true
                        }
                    }) {
                        AssistantOrAttachmentView(
                            assistant: assistant,
                            persistentAttachment: attachment)
                        .frame(width: 72.0, height: 72.0) // TODO: Having the width here seems to make the text not wrap or cut off if the lineLimit is 1.. reserach this and why this would be happening
                        
                        if attachment != nil {
                            // Attachment Type/Generated Title/Model
                            VStack(alignment: .leading, spacing: -2.0) {
                                // Attachment Type
                                var attachmentTypeDisplayName: String {
                                    guard let attachmentTypeString = attachment?.attachmentType,
                                          let attachmentType = AttachmentType(rawValue: attachmentTypeString) else {
                                        return "Other"
                                    }
                                    
                                    return switch attachmentType {
                                    case .flashcards: "Flashcards"
                                    case .image: "Image"
                                    case .pdfOrText: "File"
                                    case .voice: "Voice"
                                    case .webUrl: "Link"
                                    }
                                }
                                
                                Text(attachmentTypeDisplayName)
                                    .font(.custom(Constants.FontName.black, size: 10.0))
                                
                                // Generated Title                                     }
                                Text(attachment?.generatedTitle ?? "New Chat")
                                    .font(.custom(Constants.FontName.body, size: 12.0))
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                
                                // Model Name
                                Text(GPTModels.from(id: conversation.modelID ?? "").name)
                                    .font(.custom(Constants.FontName.lightOblique, size: 10.0))
                                
                                HStack {
                                    // Keep in Mind Chats
                                    if let keepInMindChats = try? ConversationCDHelper.getKeepingInMind(
                                        conversation: conversation,
                                        in: viewContext), !keepInMindChats.isEmpty {
                                        HStack(spacing: 0.0) {
                                            Image(systemName: "pin.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .rotationEffect(Angle.degrees(-45))
                                                .frame(width: 12.0, height: 12.0)
                                            
                                            Text("\(keepInMindChats.count)")
                                                .font(.custom(Constants.FontName.medium, size: 10.0))
                                        }
                                    }
                                    
                                    // Keep in Mind Images
                                    if let keepInMindImages = try? ConversationCDHelper.getKeepingInMindImageDataRecentFirst(
                                        conversation: conversation,
                                        in: viewContext), !keepInMindImages.isEmpty {
                                        HStack(spacing: 0.0) {
                                            Image(systemName: "photo.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 12.0, height: 12.0)
                                                .padding(.trailing, 2)
                                            
                                            Text("\(keepInMindImages.count)")
                                                .font(.custom(Constants.FontName.medium, size: 10.0))
                                        }
                                    }
                                }
                                .padding(.top, 2)
                            }
                            .padding(.trailing, 12)
                            .padding([.leading, .trailing], 4)
                        } else {
                            // My AI/Name/ModelName on Right
                            VStack(alignment: .leading, spacing: -2.0) {
                                // Name
                                if let name = conversation.assistant?.name {
                                    Text(name)
                                        .font(.custom(Constants.FontName.body, size: 14.0))
                                        .multilineTextAlignment(.leading)
                                }
                                
                                // Model Name
                                Text(GPTModels.from(id: conversation.modelID ?? "").name)
                                    .font(.custom(Constants.FontName.lightOblique, size: 10.0))
                                
                                HStack {
                                    // Keep in Mind Chats
                                    if let keepInMindChats = try? ConversationCDHelper.getKeepingInMind(
                                        conversation: conversation,
                                        in: viewContext), !keepInMindChats.isEmpty {
                                        HStack(spacing: 0.0) {
                                            Image(systemName: "pin.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .rotationEffect(Angle.degrees(-45))
                                                .frame(width: 12.0, height: 12.0)
                                            
                                            Text("\(keepInMindChats.count)")
                                                .font(.custom(Constants.FontName.medium, size: 10.0))
                                        }
                                    }
                                    
                                    // Keep in Mind Images
                                    if let keepInMindImages = try? ConversationCDHelper.getKeepingInMindImageDataRecentFirst(
                                        conversation: conversation,
                                        in: viewContext), !keepInMindImages.isEmpty {
                                        HStack(spacing: 0.0) {
                                            Image(systemName: "photo.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 12.0, height: 12.0)
                                                .padding(.trailing, 2)
                                            
                                            Text("\(keepInMindImages.count)")
                                                .font(.custom(Constants.FontName.medium, size: 10.0))
                                        }
                                    }
                                }
                                .padding(.top, 2)
                            }
                            .padding(.trailing, 12)
                        }
                    }
                    
                    // TODO: Flashcards Mini View
                }
                .foregroundStyle(Colors.text)
                .background(Rectangle()
                    .fill(Colors.foreground))
                .clipShape(RoundedRectangle(cornerRadius: 28.0))
                .frame(maxWidth: premiumUpdater.isPremium ? 250 : 180) // Max width of the assistants bubble changes depending on premium status because of the Ultra button
                .padding(.bottom, 8)
                
                Spacer()
            }
            .frame(minHeight: 42.0)
            .background(Colors.background)
            
            //            Spacer()
        }
    }
    
}

//#Preview {
//    
//    ConversationTopBarView(
//        conversation: try! CDClient.mainManagedObjectContext.fetch(Conversation.fetchRequest())[0],
//        isShowingAssistantInformationView: .constant(false),
//        isShowingAttachmentInformationView: .constant(false),
//        persistentAttachments: FetchRequest(
//            sortDescriptors: [NSSortDescriptor(key: #keyPath(PersistentAttachment.date), ascending: false)],
//            predicate: NSPredicate(format: "%K = %@", #keyPath(PersistentAttachment.conversation), try! CDClient.mainManagedObjectContext.fetch(Conversation.fetchRequest())[0])))
//    .environmentObject(PremiumUpdater())
//    
//}
