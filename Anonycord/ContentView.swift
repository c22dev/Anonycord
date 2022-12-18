//
//  ContentView.swift
//  Anonycord
//
//  Created by c22 on 18/12/2022.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecordView()
                .tabItem {
                    Label("Record", systemImage: "record.circle")
                }
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
