//
//  RecordView.swift
//  Anonycord
//
//  Created by c22 on 18/12/2022.
//

import SwiftUI
import Photos
import AVFoundation

struct RecordView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        return RecordViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

class RecordViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var movieFileOutput: AVCaptureMovieFileOutput!
    var tapCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            UIApplication.shared.alert(title:"App Message", body: "Unable to access backcam")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
        } catch {
            UIApplication.shared.alert(title:"App Message", body: "Unable to access back cam")
            return
        }
        
        movieFileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(movieFileOutput)
        
        
        let recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        recordButton.center = view.center
        recordButton.setTitle("Start", for: .normal)
        recordButton.setTitleColor(.red, for: .normal)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        captureSession.startRunning()
    }

    @objc func recordButtonTapped() {
        if movieFileOutput.isRecording {
            movieFileOutput.stopRecording()
        } else {
            movieFileOutput.startRecording(to: URL(fileURLWithPath: NSTemporaryDirectory() + "movie.mov"), recordingDelegate: self)
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            UIApplication.shared.alert(title:"App Message", body: "Error recording video: \(error!.localizedDescription)")
        } else {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func videoSaved(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        if error != nil {
            UIApplication.shared.alert(title:"App Message", body: "Error saving video: \(error!.localizedDescription)")
        } else {
            UIApplication.shared.alert(title:"App Message", body: "Video saved successfully")
            exit(0)
        }
    }
    
    @objc func viewTapped() {
        tapCount += 1
        if tapCount == 2 {
            view.backgroundColor = .white
            movieFileOutput.stopRecording()
        } else {
            view.backgroundColor = .black
        }
    }
}

