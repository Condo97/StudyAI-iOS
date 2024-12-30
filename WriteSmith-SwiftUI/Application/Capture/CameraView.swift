//
//
//  CameraView.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/7/24.
//

import AVFoundation
import Combine
import SwiftUI

// ViewModel to manage camera actions and outputs
class CameraViewModel: ObservableObject {
    
    // Define FlashMode enum
    enum FlashMode {
        case off
        case on
        case auto
    }
    
    @Published var shouldTakePhoto: Bool = false
    @Published var capturedImage: UIImage? = nil
    @Published var flashMode: FlashMode = .auto
    @Published var willUseAutomaticFlash: Bool = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var hasCamera: Bool = true
    
    init() {
        checkCameraAuthorization()
    }
    
    // Check and request camera authorization
    func checkCameraAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        authorizationStatus = status
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.authorizationStatus = granted ? .authorized : .denied
                }
            }
        }
    }
    
}

// SwiftUI wrapper for UIKit Camera View Controller
struct CameraView: UIViewControllerRepresentable {
    
    @ObservedObject var viewModel: CameraViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.delegate = context.coordinator
        cameraVC.viewModel = viewModel
        return cameraVC
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Update flash mode safely
        uiViewController.updateFlashMode(flashMode: viewModel.flashMode)
        
        // Trigger photo capture when shouldTakePhoto is set to true
        if viewModel.shouldTakePhoto {
            DispatchQueue.main.async { //[self] in
                uiViewController.capturePhoto()
                viewModel.shouldTakePhoto = false
            }
        }
    }

    // Coordinator to handle delegate methods
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        // Delegate method called when photo is captured
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                print("Error capturing photo: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self.parent.viewModel.capturedImage = image
            }
        }
    }
    
}

// UIKit Camera View Controller
class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession?
    var photoOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: AVCapturePhotoCaptureDelegate?
    var viewModel: CameraViewModel?
    
    private var flashMode: CameraViewModel.FlashMode = .off
    private var currentDevice: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup camera only if authorized
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            setupCamera()
        }
    }

    // Setup camera session and preview layer
    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        captureSession.sessionPreset = .photo

        // Setup input device
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }
        currentDevice = backCamera

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                // Add KVO observer for exposureTargetOffset
                backCamera.addObserver(self, forKeyPath: "exposureTargetOffset", options: [.new], context: nil)
            }

            // Setup output
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.isLivePhotoCaptureEnabled = false
            }

            // Setup video data output for brightness analysis (optional)
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
            if captureSession.canAddOutput(videoDataOutput) {
                captureSession.addOutput(videoDataOutput)
            }

            // Setup preview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer!.videoGravity = .resizeAspectFill
            videoPreviewLayer!.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)

            // Start session
            captureSession.startRunning()
        } catch let error {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            viewModel?.hasCamera = false
        }
    }

    // Capture photo
    func capturePhoto() {
        guard let delegate = self.delegate else { return }
        guard let viewModel = self.viewModel else { return }
        let settings = AVCapturePhotoSettings()

        let deviceHasFlash = currentDevice?.hasFlash ?? false

        switch viewModel.flashMode {
        case .off:
            settings.flashMode = .off
        case .on:
            settings.flashMode = deviceHasFlash ? .on : .off
        case .auto:
            if deviceHasFlash && viewModel.willUseAutomaticFlash {
                settings.flashMode = .on
            } else {
                settings.flashMode = .off
            }
        }

        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }

    // Update flash mode safely
    func updateFlashMode(flashMode: CameraViewModel.FlashMode) {
        self.flashMode = flashMode
        guard let device = currentDevice else { return }
        let deviceHasTorch = device.hasTorch

        do {
            try device.lockForConfiguration()

            switch flashMode {
            case .on:
                if deviceHasTorch && device.isTorchModeSupported(.on) {
                    device.torchMode = .on
                }
            case .off, .auto:
                if deviceHasTorch && device.isTorchModeSupported(.off) {
                    device.torchMode = .off
                }
            }

            device.unlockForConfiguration()
        } catch {
            print("Error locking configuration: \(error)")
        }
    }

    // Observe exposureTargetOffset to update willUseAutomaticFlash
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "exposureTargetOffset" {
            if let device = object as? AVCaptureDevice {
                let exposureOffset = device.exposureTargetOffset
                // exposureOffset is negative for underexposed, positive for overexposed
                // We'll set willUseAutomaticFlash to true if exposureOffset is below a threshold
                DispatchQueue.main.async {
                    self.viewModel?.willUseAutomaticFlash = exposureOffset < -1.0 // adjust threshold as needed
                }
            }
        }
    }

    deinit {
        currentDevice?.removeObserver(self, forKeyPath: "exposureTargetOffset")
    }

    // Implement delegate method for sample buffer (optional)
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // If needed, implement further processing of sampleBuffer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
    }
    
}
