//
//  MediaRecorder.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import AVFoundation
import Photos
import UIKit

class MediaRecorder: ObservableObject {
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private var videoOutput: AVCaptureMovieFileOutput!
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    
    private let videoRecordingDelegate = VideoRecordingDelegate()
    private let photoCaptureDelegate = PhotoCaptureDelegate()
    
    func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
        AVAudioApplication.requestRecordPermission { _ in }
        PHPhotoLibrary.requestAuthorization { _ in }
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        setupVideoInput()
        setupAudioInput()
        setupOutputs()
        
        captureSession.startRunning()
    }
    
    private func setupVideoInput() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)
    }
    
    private func setupAudioInput() {
        guard let audioCaptureDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioCaptureDevice),
              captureSession.canAddInput(audioInput) else { return }
        captureSession.addInput(audioInput)
    }
    
    private func setupOutputs() {
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
    }
    
    func startVideoRecording(completion: @escaping (URL?) -> Void) {
        deleteOldVideos()
        videoRecordingDelegate.onFinish = completion
        let videoRecordingURL = getDocumentsDirectory().appendingPathComponent("video.mov")
        videoOutput.startRecording(to: videoRecordingURL, recordingDelegate: videoRecordingDelegate)
    }
    
    func stopVideoRecording() {
        videoOutput.stopRecording()
    }
    
    func startAudioRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings: [String: Any] = [
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
        } catch {
            print("Failed to set up recording session: \(error.localizedDescription)")
        }
    }
    
    func stopAudioRecording() {
        audioRecorder.stop()
        let audioURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        promptSaveAudioToFiles(audioURL: audioURL)
    }
    
    func takePhoto() {
        guard photoOutput != nil else { return }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
    }
    
    func saveVideoToLibrary(videoURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }, completionHandler: { success, error in
            if let error = error {
                print("Error saving video: \(error.localizedDescription)")
            } else {
                print("Video saved to library")
            }
        })
    }
    
    private func deleteOldVideos() {
        let fileManager = FileManager.default
        let videoURL = getDocumentsDirectory().appendingPathComponent("video.mov")
        if fileManager.fileExists(atPath: videoURL.path) {
            try? fileManager.removeItem(at: videoURL)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func promptSaveAudioToFiles(audioURL: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [audioURL])
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootController = scene.windows.first?.rootViewController {
            rootController.present(documentPicker, animated: true, completion: nil)
        }
    }
}
