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
    @State var channelDefStr = String(AppSettings().channelDef)
    var body: some View {
        NavigationView {
            List {
                Section(header: Label("Audio Recording", systemImage: "mic"), footer: Text("Settings for audio recording. Doesn't apply to video recording's audio.")) {
                    Picker("Channels", selection: $channelDefStr) {
                        ForEach(channelsMapping.keys.sorted(), id: \.self) { abbreviation in
                            Text(channelsMapping[abbreviation] ?? abbreviation)
                                .tag(abbreviation)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: channelDefStr) { newValue in
                        AppSettings().channelDef = Int(channelDefStr) ?? 1
                    }
                    HStack(spacing: 0) {
                        Text("Sample Rate")
                        Spacer()
                        TextField("44100", text: $micSplRateStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: micSplRateStr) { newValue in
                                micSplRateStr = newValue
                            }
                            .focused($isTextFieldFocused)
                        Text("Hz")
                    }
                    Button("Confirm") {
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

let channelsMapping: [String: String] = [
            "1": "Mono",
            "2": "Stereo",
]
