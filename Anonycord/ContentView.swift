//
//  ContentView.swift
//  Anonycord
//
//  Created by c22 on 18/12/2022.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
            RecordView()
            .statusBar(hidden: true)
            .onAppear{
                let isFirstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
                if !isFirstLaunch {
                    UserDefaults.standard.set(true, forKey: "firstLaunch")
                    UIApplication.shared.alert(title: "Welcome to Anonycord !",body: "This app was made by c22dev. Credits to alecs and General Shiro for testing")
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
