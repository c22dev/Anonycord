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
            .onChange(of: isRecordingVideo) {
                withAnimation {
                    boxSize = isRecordingVideo ? 100 : (UIScreen.main.bounds.width - 60)
                }
            }
            .onChange(of: isRecordingAudio) {
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
