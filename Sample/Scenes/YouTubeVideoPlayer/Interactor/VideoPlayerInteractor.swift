//
//  VideoPlayerInteractor.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import RxSwift

protocol VideoPlayerControlled {
    func play()
    func pause()
    func stop()
    func reverse()
    func forward()
    func start()
    func seekToSeconds(_ seconds: Float)
}

final class VideoPlayerInteractor: VideoPlayerControlled {
    var videoPlayer: VideoPlayer

    init(videoPlayer: VideoPlayer) {
        self.videoPlayer = videoPlayer
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

final class NavicationObservable: ObservableObject {

    var rxViewClosed: PublishSubject<Bool> = PublishSubject()

    func closeView() {
        rxViewClosed.onNext(true)
    }
}
