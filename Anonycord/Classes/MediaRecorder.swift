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
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { _ in }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        }
        PHPhotoLibrary.requestAuthorization { _ in }
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        switch AppSettings().videoQuality {
        case "4K":
            captureSession.sessionPreset = .hd4K3840x2160
        case "1080p":
            captureSession.sessionPreset = .hd1920x1080
        default:
            captureSession.sessionPreset = .high
        }
        
        setupVideoInput()
        setupAudioInput()
        setupOutputs()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func setupVideoInput() {
        guard let captureSession = self.captureSession else {
            print("Capture session is not initialized.")
            return
        }
        
        for input in captureSession.inputs {
            if let videoInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(videoInput)
            }
        }
        
        let cameraPosition: AVCaptureDevice.Position
        var cameraType: AVCaptureDevice.DeviceType
        
        switch AppSettings().cameraType {
        case "Selfie":
            cameraPosition = .front
            cameraType = .builtInWideAngleCamera
        case "UltraWide":
            cameraPosition = .back
            cameraType = .builtInUltraWideCamera
        default:
            cameraPosition = .back
            cameraType = .builtInWideAngleCamera
        }
        
        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: cameraPosition
        ).devices
        
        guard let cameraDevice = devices.first(where: { $0.deviceType == cameraType }) else {
            print("No available camera found.")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Unable to add video input (?)")
            }
        } catch {
            print("error creating video input \(error)")
        }
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
            AVSampleRateKey: AppSettings().micSampleRate,
            AVNumberOfChannelsKey: AppSettings().channelDef,
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
                if AppSettings().crashAtEnd {
                    exitWithStyle()
                }
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
    
    func reconfigureCaptureSession() {
        guard let captureSession = self.captureSession else { return }
        captureSession.stopRunning()
        setupCaptureSession()
    }
    
    func hasUltraWideCamera() -> Bool {
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera.isConnected
        }
        return false
    }
}
