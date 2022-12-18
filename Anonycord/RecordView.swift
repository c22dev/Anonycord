//
//  RecordView.swift
//  Anonycord
//
//  Created by c22 on 18/12/2022.
//

import SwiftUI
import AVFoundation
import Photos
struct RecordView: View {
    @ObservedObject var recordView = RecordView()
    
    var body: some View {
        VStack {
            Button(action: {
                self.recordView.toggleRecording()
            }) {
                Text(recordView.isRecording ? "Stop" : "Start")
            }
            .padding()
        }
        .onAppear {
            self.recordView.start()
        }
    }
    class RecordView: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
        @Published var isRecording = false
        let session = AVCaptureSession()
        let movieOutput = AVCaptureMovieFileOutput()
        
        func start() {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            
            if let device = deviceDiscoverySession.devices.first {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    session.addInput(input)
                } catch {
                    print("Error adding input: \(error)")
                }
                
                if session.canAddOutput(movieOutput) {
                    session.addOutput(movieOutput)
                }
            }
        }
        
        func toggleRecording() {
            if !isRecording {
                // start recording
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let fileUrl = paths[0].appendingPathComponent("video.mov")
                try? FileManager.default.removeItem(at: fileUrl)
                movieOutput.startRecording(to: fileUrl, recordingDelegate: self)
            } else {
                // stop recording
                movieOutput.stopRecording()
            }
            
            isRecording.toggle()
        }
        
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            if error == nil {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                        }) { saved, error in
                            if saved {
                                print("Video saved to the camera roll")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}

