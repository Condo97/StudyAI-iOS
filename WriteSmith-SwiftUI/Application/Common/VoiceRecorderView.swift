////
////  VoiceRecorderView.swift
////  WriteSmith-SwiftUI
////
////  Created by Alex Coundouriotis on 4/14/24.
////
//
//import AVKit
//import Foundation
//import SwiftUI
//import UIKit
//
//struct VoiceRecorderView: UIViewControllerRepresentable {
//    
//    @Binding var audioRecorder: AVAudioRecorder?
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        setupAudioRecorder()
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        // Update logic if required
//    }
//    
//    private func setupAudioRecorder() {
//        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
//
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//        
//        do {
//            let audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//            audioRecorder.prepareToRecord()
//            self.audioRecorder = audioRecorder
//        } catch {
//            print("Failed to set up audio recorder: \(error)")
//        }
//    }
//    
//    private func getDocumentsDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//    
//}
