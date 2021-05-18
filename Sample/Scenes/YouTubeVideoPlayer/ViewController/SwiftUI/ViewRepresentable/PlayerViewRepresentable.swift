//
//  PlayerViewRepresentable.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import SwiftUI

struct PlayerViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> YTPlayerView {
        YTPlayerView()
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {
    }
}
