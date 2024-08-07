//
//  RecordButton.swift
//  Anonycord
//
//  Created by Constantin Clerc on 7/8/24.
//

import SwiftUI

struct RecordButton: View {
    @Binding var isRecording: Bool
    var action: () -> Void
    var icon: String
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isRecording ? "stop.circle.fill" : icon)
                .resizable()
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

struct ControlButton: View {
    var action: () -> Void
    var icon: String
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
    }
}
