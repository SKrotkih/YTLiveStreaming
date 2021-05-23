//
//  VideoPlayerBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

typealias PlayerInteractor = VideoPlayerControlled

/// SwiftUI content view for the YouTube video player
struct VideoPlayerBodyView: View {
    var interactor: PlayerInteractor
    var navigateController: NavicationObservable
    var playerView: PlayerViewRepresentable

    @State private var seekToSeconds: Float = 0.0
    @State private var isSliderChanged = false {
        didSet {
            interactor.seekToSeconds(seekToSeconds)
        }
    }

    var body: some View {
        VStack {
            Button("Close") { navigateController.closeView() }
            .foregroundColor(.gray)
            playerView
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            Spacer()
            HStack {
                Spacer()
                Slider(
                    value: $seekToSeconds,
                    in: 0...100,
                    onEditingChanged: { editing in
                        isSliderChanged = editing
                    }
                )
                Spacer()
            }
            HStack {
                Spacer()
                Button("Play") { interactor.play() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Pause") { interactor.pause() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Stop") { interactor.stop() }
                    .foregroundColor(.gray)
                Spacer()
            }
            HStack {
                Spacer()
                Button("Start") { interactor.start() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Reverse") { interactor.reverse() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Forward") { interactor.forward() }
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
        }
    }
}

struct VideoPlayerContentView_Previews: PreviewProvider {
    static var previews: some View {
        let videoPlayer = VideoPlayer(videoId: "M7lc1UVf-VE")
        let interactor = VideoPlayerInteractor(videoPlayer: videoPlayer!)
        VideoPlayerBodyView(interactor: interactor,
                            navigateController: NavicationObservable(),
                            playerView: PlayerViewRepresentable(playerView: videoPlayer!.playerView))
    }
}
