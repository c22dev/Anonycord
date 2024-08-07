//
//  PhotoCaptureDelegate.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import AVFoundation
import Photos

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error capturing photo: \(error!.localizedDescription)")
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            print("No photo data to write")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Not authorized to save photo")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photoData, options: nil)
            }, completionHandler: { success, error in
                if let error = error {
                    print("Error saving photo to library: \(error.localizedDescription)")
                } else {
                    print("Photo saved to library")
                    if AppSettings().crashAtEnd {
                        exitWithStyle()
                    }
                }
            })
        }
    }
}
