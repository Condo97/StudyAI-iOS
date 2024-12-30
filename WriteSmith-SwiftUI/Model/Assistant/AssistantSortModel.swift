//
//  AssistantSortModel.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/28/24.
//

import Foundation

struct AssistantSortModel {
    
    struct AssistantSortSpec: Identifiable {
        var id = UUID()
        var displayName: String
        var imageName: String
        var category: AssistantCategories
    }
    
    // Writing, Technical, Language, Educatin, Utilities, Travel, Business, Health & Wellness, Entertainment, Creative & Design, Carreer & Professional Development, Financial, Security, Legal, Miscellaneious
    
    static var sortItems: [AssistantCategories] = [
        .writing,
        .stem,
        .business,
        .tech,
        .health,
        .languages,
        .politics,
        .humanities,
        .law,
        .communication,
        .arts,
        .lifestyle,
        .socialSci,
        .media,
        .environment,
        .creatives,
        .general,
        .other
    ]
//        AssistantSortSpec(
//            displayName: "Writing",
//            imageName: "WritingSortImage",
//            category: .writing),
//        AssistantSortSpec(
//            displayName: "STEM",
//            imageName: "CelebritySortImage",
//            category: .stem),
//        AssistantSortSpec(
//            displayName: "Character",
//            imageName: "CharacterSortImage",
//            category: .character),
////        AssistantSortSpec(
////            displayName: "Anime",
////            imageName: "AnimeSortImage",
////            category: .anime),
//        AssistantSortSpec(
//            displayName: "Roleplay",
//            imageName: "RoleplaySortImage",
//            category: .roleplay),
//        AssistantSortSpec(
//            displayName: "Work",
//            imageName: "WorkSortImage",
//            category: .work),
//        AssistantSortSpec(
//            displayName: "Travel",
//            imageName: "TravelSortImage",
//            category: .travel),
//        AssistantSortSpec(
//            displayName: "Study",
//            imageName: "StudySortImage",
//            category: .study),
//        AssistantSortSpec(
//            displayName: "Fun",
//            imageName: "FunSortImage",
//            category: .fun),
//        AssistantSortSpec(
//            displayName: "Art",
//            imageName: "ArtSortImage",
//            category: .art),
//        AssistantSortSpec(
//            displayName: "Health",
//            imageName: "HealthSortImage",
//            category: .health),
//        AssistantSortSpec(
//            displayName: "Music",
//            imageName: "MusicSortImage",
//            category: .music),
//        AssistantSortSpec(
//            displayName: "Dev",
//            imageName: "DevSortImage",
//            category: .dev),
//        AssistantSortSpec(
//            displayName: "Game",
//            imageName: "GameSortImage",
//            category: .game)
//    ]
    
}
