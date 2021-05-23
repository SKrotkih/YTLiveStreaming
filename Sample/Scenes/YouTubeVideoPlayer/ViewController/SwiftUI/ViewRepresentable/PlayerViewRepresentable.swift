//
//  PlayerViewRepresentable.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

struct PlayerViewRepresentable: UIViewRepresentable {
    var playerView: YTPlayerView
    func makeUIView(context: Context) -> YTPlayerView {
        playerView
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {
    }
}
