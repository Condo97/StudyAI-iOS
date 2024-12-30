# StudyAI iOS App

The StudyAI iOS app. Interacts with StudyAI Server using OpenAI GPT-4o and DALL-E 3. Fully capable with image send, voice send, and more.

## Requirements

- Xcode

## Installation

1. Clone StudyAI-iOS
2. Create and fill a Keys file (see below)
3. Run the project

## Keys File
This file is to be located in 
```
CallAI > WriteSmith-SwiftUI > Constants > Keys.swift
```
You must fill the values in this to work.
```swift
struct Keys {
    
    struct Ads {
        
        struct Banner {
            static let chatView          :  String
            static let conversationView  :  String
            static let essayView         :  String
            static let exploreChatView   :  String
            static let exploreView       :  String
            static let panelView         :  String
            static let settingsView      : String

            // This may be used for all banner ads when testing
            static let debug = "ca-app-pub-3940256099942544/2934735716"
        }
        
        struct Interstitial {
            static let chatView    :  String
            static let essayView   :  String
            static let panelView   :  String

            // This may be used for all interstitial ads when testing
            static let debug = "ca-app-pub-3940256099942544/4411468910"
        }
        
    }
    
    static let sharedSecret  :  String
    
    static let airtableAPI   :  String
    
}
```

## Contribute

We would love you to contribute to **StudyAI Server**. Please feel free to submit a pull request or write my email: acoundou@gmail.com
