//
//  ImagePicker.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/4/24.
//

import PhotosUI
import SwiftUI

struct ImagePicker: ViewModifier {
    
    @Binding var isPresented: Bool
    var onSelect: (UIImage) -> Void
    
    @State private var selection: PhotosPickerItem?
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $selection)
            .onChange(of: selection) { newValue in
                if let selection = newValue {
                    Task {
                        // Set image to data from selection
                        do {
                            if let data = try await selection.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                onSelect(image)
                            }
                        } catch {
                            // TODO: Handle Errors
                            print("Error loading transferrable from photo selection in ImagePicker... \(error)")
                        }
                    }
                }
                
                // Set selection to nil
                selection = nil
            }
    }
    
}

extension View {
    
    func imagePicker(isPresented: Binding<Bool>, onSelect: @escaping (UIImage) -> Void) -> some View {
        self
            .modifier(ImagePicker(isPresented: isPresented, onSelect: onSelect))
    }
    
}
