////
////  SettingsView.swift
////  Anonycord
////
////  Created by Constantin Clerc on 30/01/2023.
////
//
//import SwiftUI
//
//struct SettingsView: View {
//    var body: some View {
//        Button("Hide Settings", action: {
//            UIApplication.shared.confirmAlert(title: "WARNING !", body: "You won't be able to show again these settings, about tab or else than RecorderView. Are you sure ?", onOK: {
//                UIApplication.shared.confirmAlert(title: "Are you sure ?", body: "You're about to hide everything. Are you really sure you want to continue ?", onOK: {
//                    UIApplication.shared.confirmAlert(title: "I'm not kidding", body: "This will edit an UserDefaults, wich can't be resetted except by reinstalling the app. Are you sure you want to go further ?", onOK: {
//                        UIApplication.shared.confirmAlert(title: "Latest warning", body: "Next time you press Yes will apply", onOK: {
//                            <#code#>
//                        }, noCancel: false)
//                    }, noCancel: false)                }, noCancel: false)
//            }, noCancel: false)
//        })
//    }
//}
//
//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
