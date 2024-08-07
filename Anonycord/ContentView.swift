//
//  ContentView.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import SwiftUI
import AVFoundation
import Photos
import UIKit

struct ContentView: View {
    @State private var showingSettings = false
    @State private var recordingSession: AVAudioSession!
    @State private var audioRecorder: AVAudioRecorder!
    @State private var videoOutput: AVCaptureMovieFileOutput!
    @State private var captureSession: AVCaptureSession!
    @State private var photoOutput: AVCapturePhotoOutput!
    @State private var isRecordingVideo = false
    @State private var isRecordingAudio = false
    @State private var videoRecordingURL: URL?
    @State private var showingFilePicker = false
    private let videoRecordingDelegate = VideoRecordingDelegate()
    private let photoCaptureDelegate = PhotoCaptureDelegate()

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    isRecordingVideo ? stopVideoRecording() : startVideoRecording()
                }) {
                    Image(systemName: isRecordingVideo ? "stop.circle.fill" : "video.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: {
                    isRecordingAudio ? stopAudioRecording() : startAudioRecording()
                }) {
                    Image(systemName: isRecordingAudio ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: {
                    takePhoto()
                }) {
                    Image(systemName: "camera.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gear.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
            .padding()
            .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
            .cornerRadius(30)
            .padding()
        }
        .background(Color.black)
        .onAppear(perform: {
            requestPermissions()
            setupCaptureSession()
        })
    }

    func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                // Handle denied access
            }
        }
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                // Handle denied access
            }
        }
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                // Handle denied access
            }
        }
    }

    func deleteOldVideos() {
        let fileManager = FileManager.default
        let videoURL = getDocumentsDirectory().appendingPathComponent("video.mov")
        if fileManager.fileExists(atPath: videoURL.path) {
            do {
                try fileManager.removeItem(at: videoURL)
                print("Old video file deleted.")
            } catch {
                print("Error deleting old video file: \(error.localizedDescription)")
            }
        }
    }

    func startVideoRecording() {
        deleteOldVideos()
        setupCaptureSession()

        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.videoRecordingURL = getDocumentsDirectory().appendingPathComponent("video.mov")
                self.videoOutput.startRecording(to: self.videoRecordingURL!, recordingDelegate: self.videoRecordingDelegate)
                self.isRecordingVideo = true

                self.videoRecordingDelegate.onFinish = { url in
                    if let url = url {
                        self.videoRecordingDelegate.saveVideoToLibrary(videoURL: url)
                    }
                    self.isRecordingVideo = false
                }
            }
        }
    }

    func stopVideoRecording() {
        if isRecordingVideo {
            videoOutput.stopRecording()
            isRecordingVideo = false
        }
    }

    func startAudioRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recordingSession = AVAudioSession.sharedInstance()
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try recordingSession.setActive(true)

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            isRecordingAudio = true
        } catch {
            print("Failed to set up recording session: \(error.localizedDescription)")
            // Handle error
        }
    }

    func stopAudioRecording() {
        if isRecordingAudio {
            audioRecorder.stop()
            audioRecorder = nil
            isRecordingAudio = false
            let audioURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            promptSaveAudioToFiles(audioURL: audioURL)
        }
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        // Video input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        // Audio input
        guard let audioCaptureDevice = AVCaptureDevice.default(for: .audio) else { return }
        let audioInput: AVCaptureDeviceInput
        do {
            audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        } else {
            return
        }

        // Output
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            return
        }

        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.startRunning()
    }

    func takePhoto() {
        guard photoOutput != nil else { return }

        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func promptSaveAudioToFiles(audioURL: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [audioURL])
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootController = scene.windows.first?.rootViewController {
            rootController.present(documentPicker, animated: true, completion: nil)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
