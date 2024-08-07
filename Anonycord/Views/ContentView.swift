//
//  ContentView.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSettings = false
    @State private var isRecordingVideo = false
    @State private var isRecordingAudio = false
    @State private var videoRecordingURL: URL?
    @State private var showingFilePicker = false
    @State private var boxSize: CGFloat = UIScreen.main.bounds.width - 60
    @StateObject private var mediaRecorder = MediaRecorder()
    
    var body: some View {
        VStack {
            Spacer() // spacer sandwich 🥪
            if !isRecordingAudio && !isRecordingVideo {
                Image(uiImage: Bundle.main.icon!)
                    .cornerRadius(10)
                    .transition(.scale)
                Text("Anonycord")
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold)) // goofy ahh <16.0 swiftUI
                    .transition(.scale)
                Text("by c22dev")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack {
                if !isRecordingAudio {
                    RecordButton(isRecording: $isRecordingVideo, action: toggleVideoRecording, icon: "video.circle.fill")
                        .transition(.scale)
                    if !isRecordingVideo {
                        Spacer()
                    }
                }
                
                if !isRecordingVideo {
                    RecordButton(isRecording: $isRecordingAudio, action: toggleAudioRecording, icon: "mic.circle.fill")
                        .transition(.scale)
                    if !isRecordingAudio {
                        Spacer()
                    }
                }
                
                if !isRecordingVideo && !isRecordingAudio {
                    ControlButton(action: takePhoto, icon: "camera.circle.fill")
                        .transition(.scale)
                    Spacer()
                    ControlButton(action: { showingSettings.toggle() }, icon: "gear.circle.fill")
                        .sheet(isPresented: $showingSettings) {
                            SettingsView()
                        }
                        .transition(.scale)
                }
            }
            .padding()
            .frame(width: boxSize)
            .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
            .cornerRadius(30)
            .padding()
            // This method (and the one bellow) are deprecated in iOS 17. I'll still use this for lower versions.
            // If you want to add higher version support only remove the _ in.
            .onChange(of: isRecordingVideo) { _ in
                withAnimation {
                    boxSize = isRecordingVideo ? 100 : (UIScreen.main.bounds.width - 60)
                }
            }
            .onChange(of: isRecordingAudio) { _ in
                withAnimation {
                    boxSize = isRecordingAudio ? 100 : (UIScreen.main.bounds.width - 60)
                }
            }
        }
        .background(Color.black)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        mediaRecorder.requestPermissions()
        mediaRecorder.setupCaptureSession()
    }
    
    private func toggleVideoRecording() {
        if isRecordingVideo {
            mediaRecorder.stopVideoRecording()
        } else {
            mediaRecorder.startVideoRecording { url in
                if let url = url {
                    mediaRecorder.saveVideoToLibrary(videoURL: url)
                }
                isRecordingVideo = false
            }
        }
        isRecordingVideo.toggle()
    }
    
    private func toggleAudioRecording() {
        if isRecordingAudio {
            mediaRecorder.stopAudioRecording()
        } else {
            mediaRecorder.startAudioRecording()
        }
        isRecordingAudio.toggle()
    }
    
    private func takePhoto() {
        mediaRecorder.takePhoto()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
