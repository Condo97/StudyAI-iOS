//
//  ScanProblemCameraView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/7/24.
//

import SwiftUI

struct ScanProblemCameraView: View {
    
    struct Mode {
        let name: String
        let captureIcon: Image
        let captureBackgroundColor: Color
    }
    
    var onAttach: (UIImage) -> Void
    
    @StateObject private var cameraViewModel: CameraViewModel = CameraViewModel()
    
    @State private var selectedModeIndex: Int = 2
    
    @State private var isShowingImagePicker: Bool = false
    
    private let modes: [Mode] = [
        Mode(name: "History", captureIcon: Image(Constants.ImageName.CaptureIcons.history), captureBackgroundColor: .orange),
        Mode(name: "Math", captureIcon: Image(Constants.ImageName.CaptureIcons.math), captureBackgroundColor: .blue),
        Mode(name: "General", captureIcon: Image(Constants.ImageName.CaptureIcons.general), captureBackgroundColor: Colors.elementBackgroundColor),
        Mode(name: "Physics", captureIcon: Image(Constants.ImageName.CaptureIcons.physics), captureBackgroundColor: .red),
        Mode(name: "Chemistry", captureIcon: Image(Constants.ImageName.CaptureIcons.chemistry), captureBackgroundColor: .yellow),
        Mode(name: "Literature", captureIcon: Image(Constants.ImageName.CaptureIcons.literature), captureBackgroundColor: .blue),
        Mode(name: "Geometry", captureIcon: Image(Constants.ImageName.CaptureIcons.geometry), captureBackgroundColor: .purple),
        Mode(name: "Language", captureIcon: Image(Constants.ImageName.CaptureIcons.language), captureBackgroundColor: .blue),
        Mode(name: "Economics", captureIcon: Image(Constants.ImageName.CaptureIcons.economics), captureBackgroundColor: .green)
    ]//["History", "Math", "General", "test", "test"]
    
    var body: some View {
        CameraView(viewModel: cameraViewModel)
            .background(.black)
            .onReceive(cameraViewModel.$capturedImage) { value in
                if let value = value {
                    onAttach(value)
                }
            }
            .overlay(alignment: .bottom) {
                // Control
                VStack {
                    // Scan type
                    ModeSelectorView(
                        selectedModeIndex: $selectedModeIndex,
                        modes: modes.map(\.name))
                    .frame(height: 50.0)
                    
                    HStack {
                        Spacer()
                        
                        // Flash
                        Button(action: {
                            switch cameraViewModel.flashMode {
                            case .off:
                                cameraViewModel.flashMode = .auto
                            case .on:
                                cameraViewModel.flashMode = .off
                            case .auto:
                                cameraViewModel.flashMode = .on
                            }
                        }) {
                            Group {
                                switch cameraViewModel.flashMode {
                                case .off:
                                    Image(systemName: "bolt.slash")
                                case .on:
                                    Image(systemName: "bolt.fill")
                                case .auto:
                                    // TODO: Make it blink off and on if will use automatic flash
                                    if cameraViewModel.willUseAutomaticFlash {
                                        Image(systemName: "bolt.badge.a.fill")
                                            .foregroundStyle(.yellow)
                                    } else {
                                        Image(systemName: "bolt.badge.a")
                                    }
                                }
                            }
                            .imageScale(.large)
                            .foregroundStyle(.white)
                        }
                        .frame(width: 100.0)
                        
                        Spacer()
                        
                        // Capture
                        Button(action: {
                            cameraViewModel.shouldTakePhoto = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(modes[selectedModeIndex].captureBackgroundColor)
                                    .frame(width: 78.0, height: 78.0)
                                Circle()
                                    .stroke(.black, lineWidth: 1.0)
                                    .opacity(0.2)
                                    .frame(width: 70.0, height: 70.0)
                                modes[selectedModeIndex].captureIcon
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40.0)
                                    .foregroundStyle(.white)
                            }
                            .animation(nil, value: UUID())
                        }
                        
                        Spacer()
                        
                        // Import
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 100.0)
                        
                        Spacer()
                    }
                }
                .padding(.vertical)
            }
            .overlay {
                // Camera loading error handling
                if cameraViewModel.authorizationStatus == .denied || cameraViewModel.authorizationStatus == .restricted {
                    VStack {
                        Text("Allow camera access in settings.")
                        Button("Open Settings") {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                    }
                } else if !cameraViewModel.hasCamera {
                    Text("No camera detected.")
                }
            }
            .ignoresSafeArea()
            .imagePicker(
                isPresented: $isShowingImagePicker,
                onSelect: onAttach)
    }
    
}

#Preview {
    ScanProblemCameraView(onAttach: { image in
        
    })
}
