//
//  AssistantCategories.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/28/24.
//

import Foundation
import UIKit

enum AssistantCategories: String, Codable, Identifiable {
    
    var id: Self {
        self
    }
    
    case writing = "Writing"
    case stem = "STEM"
    case business = "Business"
    case tech = "Tech"
    case health = "Health"
    case languages = "Languages"
    case politics = "Politics"
    case humanities = "Humanities"
    case law = "Law"
    case communication = "Communication"
    case arts = "Arts"
    case lifestyle = "Lifestyle"
    case socialSci = "SocialSci"
    case media = "Media"
    case environment = "Environment"
    case creatives = "Creatives"
    
    case general = "General"
    case other = "Other"
    
}

extension AssistantCategories {
    
    var displayName: String {
        switch self {
        case .writing: "Writing"
        case .stem: "STEM"
        case .business: "Business"
        case .tech: "Tech"
        case .health: "Health"
        case .languages: "Languages"
        case .politics: "Politics"
        case .humanities: "Humanities"
        case .law: "Law"
        case .communication: "Communication"
        case .arts: "Arts"
        case .lifestyle: "Lifestyle"
        case .socialSci: "SocialSci"
        case .media: "Media"
        case .environment: "Environment"
        case .creatives: "Creatives"
        
        case .general: "General"
        case .other: "Other"
        }
    }
    
    var imageName: String? {
        switch self {
        case .writing: "WritingSortImage"
        case .stem: "STEMSortImage"
        case .business: "BusinessSortImage"
        case .tech: "TechSortImage"
        case .health: "HealthSortImage"
        case .languages: "LanguagesSortImage"
        case .politics: "PoliticsSortImage"
        case .humanities: "HumanitiesSortImage"
        case .law: "LawSortImage"
        case .communication: "CommunicationSortImage"
        case .arts: "ArtsSortImage"
        case .lifestyle: "LifestyleSortImage"
        case .socialSci: "SocialSciSortImage"
        case .media: "MediaSortImage"
        case .environment: "EnvironmentSortImage"
        case .creatives: "CreativesSortImage"
        default: nil
            
//        case .general: "GeneralSortImage"
//        case .other: "OtherSortImage"
        }
    }
    
    
//    var colorName: String {
//        switch self {
//        case .writing: "WritingAssistantCategoryColor"
//        case .celebrity: "CelebrityAssistantCategoryColor"
//        case .character: "CharacterAssistantCategoryColor"
//        case .anime: "AnimeAssistantCategoryColor"
//        case .roleplay: "RoleplayAssistantCategoryColor"
//        case .work: "WorkAssistantCategoryColor"
//        case .travel: "TravelAssistantCategoryColor"
//        case .study: "StudyAssistantCategoryColor"
//        case .fun: "FunAssistantCategoryColor"
//        case .art: "ArtAssistantCategoryColor"
//        case .health: "HealthAssistantCategoryColor"
//        case .music: "MusicAssistantCategoryColor"
//        case .dev: "DevAssistantCategoryColor"
//        case .game: "GameAssistantCategoryColor"
//            
//        case .general: "GeneralAssistantCategoryColor"
//        case .other: "OtherAssistantCategoryColor"
//        }
//    }
    
//    var color: UIColor? {
//        UIColor(named: colorName)
//    }
    
}
