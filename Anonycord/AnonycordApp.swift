//
//  AnonycordApp.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import SwiftUI

@main
struct AnonycordApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppSettings: ObservableObject {
    @AppStorage("micSampleRate") var micSampleRate: Int = 44100
    @AppStorage("channelDef") var channelDef: Int = 1
}
