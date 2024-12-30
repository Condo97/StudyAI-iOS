//
//  KeyboardReadable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 11/1/23.
//

import Combine
import UIKit


enum KeyboardStatus {
    case willShow
    case isShowing
    case willHide
    case isHidden
}

/// Publisher to read keyboard changes.
protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<KeyboardStatus, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<KeyboardStatus, Never> {
        Publishers.Merge4(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in .willShow },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidShowNotification)
                .map { _ in .isShowing },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in .willHide },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardDidHideNotification)
                .map { _ in .isHidden }
        )
        .eraseToAnyPublisher()
    }
}
