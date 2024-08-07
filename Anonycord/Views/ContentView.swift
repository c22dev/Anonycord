//
//  ContentView.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingSettings = false
    @State private var isRecordingVideo = false
    @State private var isRecordingAudio = false
    @State private var videoRecordingURL: URL?
    @State private var showingFilePicker = false
    @State private var boxSize: CGFloat = UIScreen.main.bounds.width - 60
    @StateObject private var mediaRecorder = MediaRecorder()
    @State private var inBeta = true
    
    var body: some View {
        ZStack {
            if isRecordingAudio || isRecordingVideo {
                Rectangle()
                    .fill(Color.black)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if isRecordingVideo {
                            toggleVideoRecording()
                        }
                        if isRecordingAudio {
                            toggleAudioRecording()
                        }
                    }
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }

            VStack {
                Spacer() // spacer sandwich 🥪
                if !isRecordingAudio && !isRecordingVideo {
                    Image(uiImage: Bundle.main.icon!)
                        .cornerRadius(10)
                        .transition(.scale)
                    Text("Anonycord")
                        .font(.system(size: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold))
                        .transition(.scale)
                    if inBeta {
                        Text("v\(Bundle.main.releaseVersionNumber ?? "0.0") Beta \(Bundle.main.buildVersionNumber ?? "0") - by c22dev")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else {
                        Text("v\(Bundle.main.releaseVersionNumber ?? "0.0") - by c22dev")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if !appSettings.hideAll || (!isRecordingAudio && !isRecordingVideo) {
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
                                    SettingsView(mediaRecorder: mediaRecorder)
                                }
                                .transition(.scale)
                        }
                    }
                    .padding()
                    .frame(width: boxSize)
                    .background(VisualEffectBlur(blurStyle: .systemThinMaterialDark))
                    .cornerRadius(30)
                    .padding()
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
                if !isRecordingAudio && !isRecordingVideo && appSettings.showSettingsAtBttm {
                    Text("Current Parameters : \(appSettings.videoQuality), \(appSettings.cameraType)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
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
            .environmentObject(AppSettings())
    }
}
