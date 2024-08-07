//
//  SettingsView.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import SwiftUI

struct SettingsView: View {
    @State var micSplRateStr = String(AppSettings().micSampleRate)
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        NavigationView {
            List {
                Section(header: Label("Audio Recording", systemImage: "mic"), footer: Text("Settings for audio recording. Doesn't apply to video recording's audio.")) {
                    HStack(spacing: 0) {
                        Text("Sample Rate")
                        Spacer()
                        TextField("44100", text: $micSplRateStr)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: micSplRateStr) { newValue in
                                micSplRateStr = newValue
                            }
                            .focused($isTextFieldFocused)
                        Text("Hz")
                    }
                    Button("Save") {
                        isTextFieldFocused = false
                        AppSettings().micSampleRate = Int(micSplRateStr) ?? 44100
                        micSplRateStr = String(AppSettings().micSampleRate)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
