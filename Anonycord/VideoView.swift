//
//  VideoView.swift
//  Anonycord
//
//  Created by Constantin Clerc on 18/12/2022.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @ObservedObject var viewModel: VideoPlayerViewModel
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: viewModel.urlPath!))
    }
}
