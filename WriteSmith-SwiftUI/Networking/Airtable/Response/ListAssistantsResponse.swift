//
//  ListAssistantsResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/12/24.
//

import Foundation

struct ListAssistantsResponse: Codable {
    
    struct Record: Codable {
        
        struct Assistant: Codable {
            
            struct ImageInfo: Codable {
                
                struct ThumbnailSizes: Codable {
                    
                    struct Thumbnail: Codable {
                        
                        let url: String?
                        let width: Int?
                        let height: Int?
                        
                        enum CodingKeys: String, CodingKey {
                            case url
                            case width
                            case height
                        }
                        
                    }
                    
                    let small: Thumbnail?
                    let large: Thumbnail?
                    let full: Thumbnail?
                    
                    enum CodingKeys: String, CodingKey {
                        case small
                        case large
                        case full
                    }
                    
                }
                
                let id: String?
                let width: Int?
                let height: Int?
                let url: String?
                let filename: String?
                let size: Int64?
                let type: String?
                let thumbnails: ThumbnailSizes?
                
                enum CodingKeys: String, CodingKey {
                    case id
                    case width
                    case height
                    case url
                    case filename
                    case size
                    case type
                    case thumbnails
                }
                
            }
            
            let name: String?
            let category: String?
            let subtitle: String?
            let shortDescription: String?
            let mediumDescription: String?
            let whoItsForTitle: String?
            let whoItsForDescription: String?
            let whoItsForExample1: String?
            let whoItsForExample2: String?
            let whoItsForExample3: String?
            let whoItsForExample4: String?
            let howToUseTitle: String?
            let howToUseDescription1: String?
            let howToUseDescription2: String?
            let howToUseDescription3: String?
            let howToUseDescription4: String?
            let howToUseDescription5: String?
            let faq1Title: String?
            let faq1Description: String?
            let faq2Title: String?
            let faq2Description: String?
            let faq3Title: String?
            let faq3Description: String?
            let faq4Title: String?
            let faq4Description: String?
            let systemPrompt: String?
            let initialMessage: String?
            let emoji: String?
            let image: [ImageInfo]?
            let usageMessages: Int64?
            let usageUsers: Int64?
            let updateEpochTime: Int64?
            
            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case category = "Category"
                case subtitle = "Subtitle"
                case shortDescription = "ShortDescription"
                case mediumDescription = "MediumDescription"
                case whoItsForTitle = "WhoItsForTitle"
                case whoItsForDescription = "WhoItsForDescription"
                case whoItsForExample1 = "WhoItsForExample1"
                case whoItsForExample2 = "WhoItsForExample2"
                case whoItsForExample3 = "WhoItsForExample3"
                case whoItsForExample4 = "WhoItsForExample4"
                case howToUseTitle = "HowToUseTitle"
                case howToUseDescription1 = "HowToUseDescription1"
                case howToUseDescription2 = "HowToUseDescription2"
                case howToUseDescription3 = "HowToUseDescription3"
                case howToUseDescription4 = "HowToUseDescription4"
                case howToUseDescription5 = "HowToUseDescription5"
                case faq1Title = "FAQ1Title"
                case faq1Description = "FAQ1Description"
                case faq2Title = "FAQ2Title"
                case faq2Description = "FAQ2Description"
                case faq3Title = "FAQ3Title"
                case faq3Description = "FAQ3Description"
                case faq4Title = "FAQ4Title"
                case faq4Description = "FAQ4Description"
                case systemPrompt = "SystemPrompt"
                case initialMessage = "InitialMessage"
                case emoji = "Emoji"
                case image = "Image"
                case usageMessages = "UsageMessages"
                case usageUsers = "UsageUsers"
                case updateEpochTime = "UpdateEpochTime"
            }
            
        }
        
        let id: String?
        let createdTime: String?
        let fields: Assistant?
        
        enum CodingKeys: String, CodingKey {
            case id
            case createdTime
            case fields
        }
        
    }
    
    let records: [Record]?
    let offset: String?
    
    enum CodingKeys: String, CodingKey {
        case records
        case offset
    }
    
}
