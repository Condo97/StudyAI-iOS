//
//  AttachVoiceButton.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/14/24.
//

import AVKit
import SwiftUI

struct AttachVoiceButton: View {
    
    @Binding var voiceDocumentsFilepath: String?
    var subtitle: LocalizedStringKey// = "Record or upload a lecture, speech, call, any voice recording."
    
    
    private static let recordVoiceButtonNamespaceID = "recordVoiceButton"
    
    
    @Namespace private var namespace
    
    @Environment(\.colorScheme) private var colorScheme
    
    
    @State private var avAudioRecorder: AVAudioRecorder?
    
    @State private var timer: Timer?
    
    @State private var isRecordingVoice: Bool = false
    
    @State private var isDisplayingRecordPopup: Bool = false
    @State private var isDisplayingFileImporter: Bool = false
    
    @State private var isShowingFileImporter: Bool = false
    
    @State private var alertShowingErrorAttaching: Bool = false
    @State private var alertShowingErrorReading: Bool = false
    @State private var alertShowingNoMicrophoneAccess: Bool = false
    
    @State private var savedAudioFilename: String?
    
    @State private var meters: [Float] = []
    
    @State private var attachedVoiceURL: URL?
    
    
    var body: some View {
        Button(action: {
            isDisplayingRecordPopup = true
//            isShowingFileImporter = true
        }) {
            VStack(alignment: .leading) {
                HStack {
//                    Text(Image(systemName: "waveform"))
                    Text("🎤")
                        .font(.custom(Constants.FontName.body, size: 20.0))
                        .foregroundStyle(colorScheme == .dark ? Colors.text : Colors.elementBackgroundColor)
                        .padding(4)
                        .frame(width: 38.0, height: 38.0)
                        .background(Colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                
                    Text("Voice")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                HStack {
                    Text(subtitle)
                        .font(.custom(Constants.FontName.body, size: 10.0))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Colors.text)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $isDisplayingRecordPopup) {
            ZStack {
                VStack {
                    Text("Add Voice")
                        .font(.custom(Constants.FontName.heavy, size: 24.0))
                        .foregroundStyle(Colors.text)
                        .padding(.top)
                    
                    VolumeVisualizerView(
                        meters: $meters,
                        barCount: 128,
                        barSpacing: 1.0,
                        defaultZeroHeight: 0.01,
                        heightMultiplier: 50.0)
                    .foregroundStyle(Colors.elementBackgroundColor)
                    .padding()
                    .frame(height: 150.0)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                    HStack {
                        Spacer()
                        
                        Spacer()
                        
                        Button(action: {
                            if avAudioRecorder?.isRecording ?? false {
                                DispatchQueue.main.async {
                                    // Stop recording, set isRecording to false, and set voiceDocumentsFilepath to savedAudioFilename since the savedAudioFilename is the documents directory filepath for the recorded voice
                                    self.stopRecording()
                                    self.isRecordingVoice = false
                                    self.voiceDocumentsFilepath = self.savedAudioFilename
                                }
                            } else {
                                DispatchQueue.main.async {
                                    // Setup audio session and recorder, start recording, and set isRecordingVoice to true
                                    AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                                        if granted {
                                            self.setupAudioRecorder()
                                            self.startRecording()
                                            self.isRecordingVoice = true
                                        } else {
                                            // TODO: Handle Recording Not Granted
                                            alertShowingNoMicrophoneAccess = true
                                        }
                                    })
                                }
                            }
                        }) {
                            if isRecordingVoice {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4.0)
                                        .fill(Colors.buttonBackground)
                                        .frame(width: 30.0, height: 30.0)
                                    
                                    Circle()
                                        .stroke(lineWidth: 2.0)
                                        .fill(Colors.buttonBackground)
                                        .frame(width: 80.0)
                                }
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Colors.buttonBackground)
                                        .frame(width: 80.0)
                                    
                                    Circle()
                                        .stroke(lineWidth: 2.0)
                                        .fill(Colors.foreground)
                                        .frame(width: 75.0)
                                    
                                    Text(Image(systemName: "waveform"))
                                        .font(.custom(Constants.FontName.heavy, size: 28.0))
                                        .foregroundStyle(Colors.elementTextColor)
                                }
                            }
                        }
                        
                        Button(action: {
                            isDisplayingRecordPopup = false
                            isShowingFileImporter = true
                        }) {
                            Text(Image(systemName: "folder.badge.plus"))
                                .font(.custom(Constants.FontName.body, size: 24.0))
                                .foregroundStyle(Colors.buttonBackground)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .background(Colors.background)
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isDisplayingRecordPopup = false
                        }) {
                            Image(systemName: "chevron.down")
                                .imageScale(.large)
                        }
                        .padding()
                        .foregroundStyle(Colors.buttonBackground)
                    }
                    
                    Spacer()
                }
                .onAppear {
                    AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                        if granted {
                            setupAudioSession()
        //                    setupAudioRecorder()
                        } else {
                            // TODO: Handle Recording Not Granted
                            alertShowingNoMicrophoneAccess = true
                        }
                    })
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Couldn't Read File", isPresented: $alertShowingErrorReading, actions: {
            Button("Close", action: {
                
            })
        }) {
            Text("Please ensure the file is audio and try again.")
        }
        .alert("Enable Microphone Access", isPresented: $alertShowingNoMicrophoneAccess, actions: {
            Button("Close", role: .cancel, action: {
                
            })
            
            Button("Open Settings", action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
        }) {
            Text("Please go into Settings > StudyAI and enable Microphone Access to record voice.")
        }
        .onChange(of: attachedVoiceURL) { newValue in
            // Ensure unwrap voice url, otherwise show alert
            guard let newValue = newValue else {
                alertShowingErrorAttaching = true
                return
            }
            
            // Save to documents directory
            let newFileName: String
            do {
                newFileName = try DocumentSaver.saveSecurityScopedFileToDocumentsDirectory(from: newValue)
            } catch {
                // Show error alert and return
                print("Error saving PDF or text to DocumentSaver in AttachmentsView... \(error)")
                alertShowingErrorAttaching = true
                return
            }
            
            // Set voiceDocumentsFilepath to newFileName
            self.voiceDocumentsFilepath = newFileName
        }
        .onChange(of: isShowingFileImporter) { newValue in
            // If not isShowingFileImporter set isDisplayingRecordPopup to true since we want the record popup to show up when the file importer is dismissed
            if !newValue {
                isDisplayingRecordPopup = true
            }
        }
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.audiovisualContent],
            onCompletion: { result in
                // Get resultUrl from result
                let resultUrl = try? result.get()
                
                // Set attachedVoiceURL to resultUrl
                self.attachedVoiceURL = resultUrl
            })
        .alert("Error Attatching Audio", isPresented: $alertShowingErrorAttaching, actions: {
            Button("Close", action: {
                
            })
        }) {
            Text("There was an error attaching your audio file. Please try again.")
        }
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session. Error: \(error)")
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
    }
    
    private func setupAudioRecorder() {
        // Ensure you handle permissions and the session setup appropriately
        let audioFilename = "recording\(UUID()).m4a"
        let audioPath = getDocumentsDirectory().appendingPathComponent(audioFilename)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // Set savedAudioFilename to audioFilename
        self.savedAudioFilename = audioFilename
        
        do {
            let newRecorder = try AVAudioRecorder(url: audioPath, settings: settings)
            newRecorder.isMeteringEnabled = true
            newRecorder.prepareToRecord()
            self.avAudioRecorder = newRecorder
        } catch {
            print("Failed to setup audio recorder: \(error)")
        }
    }
    
    private func startRecording() {
        // Start recording and timer which is used for the waveform
        avAudioRecorder?.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            self.avAudioRecorder?.updateMeters()
            self.meters.append((50.0 + (self.avAudioRecorder?.averagePower(forChannel: 0) ?? 0.0)) / 50.0) // TODO: Normalize to range and just make the recording button bounce
        }
    }
    
    private func stopRecording() {
        // Stop recording and timer
        avAudioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        
        print("Stopped Recording")
        print(try? DocumentSaver.getData(from: savedAudioFilename ?? "")?.count)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
}

//#Preview {
//    
//    AttachVoiceButton(
//        voiceDocumentsFilepath: .constant(nil),
//        subtitle: "Record or upload a lecture, speech, call, any voice recording.")
//    
//}
