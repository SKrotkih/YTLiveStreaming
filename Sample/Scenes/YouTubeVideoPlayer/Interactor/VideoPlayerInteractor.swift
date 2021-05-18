//
//  VideoPlayerInteractor.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import Foundation

protocol VideoPlayerControlled {
    func play()
    func pause()
    func stop()
    func reverse()
    func forward()
    func start()
    func seekToSeconds(_ seconds: Float)
}

protocol RouterControlled {
    func closeView()
}

final class VideoPlayerInteractor: VideoPlayerControlled {
    var videoPlayer: VideoPlayer

    init(videoId: String) {
        videoPlayer = VideoPlayer(videoId: videoId)
    }

    func play() {
        videoPlayer.playVideo()
    }

    func pause() {
        videoPlayer.pause()
    }

    func stop() {
        videoPlayer.stop()
    }

    func reverse() {
        videoPlayer.reverse()
    }

    func forward() {
        videoPlayer.forward()
    }

    func start() {
        videoPlayer.start()
    }

    func seekToSeconds(_ seconds: Float) {
        videoPlayer.seek(toTime: seconds)
    }
}

extension VideoPlayerInteractor: RouterControlled {
    func closeView() {
    }
}
