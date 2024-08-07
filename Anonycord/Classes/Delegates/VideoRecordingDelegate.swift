//
//  VideoRecordingDelegate.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import AVFoundation
import Photos

class VideoRecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    var onFinish: ((URL?) -> Void)?
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            onFinish?(nil)
        } else {
            print("Video recording finished: \(outputFileURL)")
            onFinish?(outputFileURL)
        }
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
}
