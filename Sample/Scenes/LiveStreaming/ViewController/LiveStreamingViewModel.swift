//
//  LiveStreamingViewModel.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import Foundation
import YTLiveStreaming
import RxSwift

class LiveStreamingViewModel: NSObject {
    // Dependebcies
    var broadcastsAPI: BroadcastsAPI!

    var rxDidUserFinishWatchVideo = PublishSubject<Bool>()
    var rxStateDescription = PublishSubject<String>()
    var rxError = PublishSubject<String>()

    fileprivate var liveBroadcast: LiveBroadcastStreamModel?

    fileprivate func didUserFinishWatchVideo() {
        rxDidUserFinishWatchVideo.onNext(true)
    }
}

// MARK: -

extension LiveStreamingViewModel {
    private func startBroadcast(_ liveBroadcast: LiveBroadcastStreamModel) {
        self.liveBroadcast = liveBroadcast

        print("Watch the live video here: https://www.youtube.com/watch?v=\(liveBroadcast.id)")

        Router.showLiveVideoViewController()
    }
}

// MARK: Live stream publishing output protocol

extension LiveStreamingViewModel: YouTubeLiveVideoPublisher {
    func willStartPublishing(completed: @escaping (String?, NSDate?) -> Void) {
        guard let broadcast = self.liveBroadcast else {
            rxError.onNext("Need a broadcast object to start live video!")
            return
        }
        guard let delegate = self as? LiveStreamTransitioning else {
            rxError.onNext("The Model does not conform LiveStreamTransitioning protocol")
            return
        }
        broadcastsAPI.startBroadcast(broadcast, delegate: delegate, completion: { streamName, streamUrl, scheduledStartTime in
            if let streamName = streamName,
                let streamUrl = streamUrl,
                let scheduledStartTime = scheduledStartTime {
                let streamUrl = "\(streamUrl)/\(streamName)"
                let startTime = scheduledStartTime as NSDate?
                completed(streamUrl, startTime)
            }
        })
    }

    func finishPublishing() {
        guard let broadcast = self.liveBroadcast else {
            self.didUserFinishWatchVideo()
            return
        }
        broadcastsAPI.completeBroadcast(broadcast, completion: { _ in
            self.didUserFinishWatchVideo()
        })
    }

    func didUserCancelPublishingVideo() {
        guard let broadcast = self.liveBroadcast else {
            self.didUserFinishWatchVideo()
            return
        }
        broadcastsAPI.deleteBroadcast(id: broadcast.id, completion: { success in
            if success {
                print("Broadcast \"\(broadcast.id)\" was deleted!")
            } else {
                self.rxError.onNext("System detected error while deleting the video./nTry to delete it in your YouTube account")
            }
            self.didUserFinishWatchVideo()
        })
    }
}

extension LiveStreamingViewModel {

    func didTransitionToLiveStatus() {
        rxStateDescription.onNext("● LIVE")
    }

    func didTransitionToStatus(broadcastStatus: String?, streamStatus: String?, healthStatus: String?) {
        if let broadcastStatus = broadcastStatus,
            let streamStatus = streamStatus,
            let healthStatus = healthStatus {
            let text = "status: \(broadcastStatus) [\(streamStatus);\(healthStatus)]"
            rxStateDescription.onNext(text)
        }
    }
}
