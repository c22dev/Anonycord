//
//  AboutView.swift
//  TSSwissKnife
//
//  Created by c22 on 17/12/2022.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
           VStack(alignment: .center) {
               Image("mypage-icon")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: 100, height: 100)
                   .clipShape(Circle())

               Text("c22dev")
                   .font(.largeTitle)
                   .padding()

               Text("Welcome to my Anonymous Recorder ! Free and open, hope you enjoy it !")
                   .font(.body)
                   .padding()

               Button(action: {
                   if let url = URL(string: "https://github.com/c22dev/Anonycord") {
                       UIApplication.shared.open(url)
                   }
               }) {
                   Text("Visit the GitHub repo")
               }
               .padding()
           }
       }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
