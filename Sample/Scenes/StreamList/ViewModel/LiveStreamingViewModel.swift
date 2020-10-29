//
//  LiveStreamingViewModel.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import UIKit
import YTLiveStreaming

class LiveStreamingViewModel: NSObject {

    // Dependebcies
    var broadcastsAPI: BroadcastsAPI!
    weak var liveViewController: LFLiveViewController!

    fileprivate var liveBroadcast: LiveBroadcastStreamModel?
}

// MARK: -

extension LiveStreamingViewModel {

    private func startBroadcast(_ liveBroadcast: LiveBroadcastStreamModel) {
        self.liveBroadcast = liveBroadcast

        print("Watch the live video here: https://www.youtube.com/watch?v=\(liveBroadcast.id)")

        Router.showLiveVideoViewController()
    }

    fileprivate func dismissVideoStreamViewController() {
        DispatchQueue.performUIUpdate { [weak self] in
            self?.liveViewController.dismiss(animated: true, completion: {
            })
        }
    }
}

// MARK: Live stream publishing output protocol

extension LiveStreamingViewModel: YouTubeLiveVideoPublisher {

    func startPublishing(completed: @escaping (String?, String?) -> Void) {
        guard let broadcast = self.liveBroadcast else {
            assert(false, "Need Broadcast object for starting live video!")
            return
        }
        guard let delegate = self as? LiveStreamTransitioning else {
            return
        }
        broadcastsAPI.startBroadcast(broadcast,
                                               delegate: delegate,
                                               completion: { streamName, streamUrl, scheduledStartTime in
            if let streamName = streamName, let streamUrl = streamUrl, let scheduledStartTime = scheduledStartTime {
                self.liveViewController.scheduledStartTime = scheduledStartTime as NSDate?
                completed(streamUrl, streamName)
            }
        })
    }

    func finishPublishing() {
        guard let broadcast = self.liveBroadcast else {
            self.dismissVideoStreamViewController()
            return
        }
        broadcastsAPI.completeBroadcast(broadcast, completion: { _ in
            self.dismissVideoStreamViewController()
        })
    }

    func cancelPublishing() {
        guard let broadcast = self.liveBroadcast else {
            self.dismissVideoStreamViewController()
            return
        }
        broadcastsAPI.deleteBroadcast(id: broadcast.id, completion: { success in
            if success {
                print("Broadcast \"\(broadcast.id)\" was deleted!")
            } else {
                Alert.sharedInstance.showOk("Sorry, system detected error while deleting the video.",
                                            message: "Try to delete it in your YouTube account")
            }
            self.dismissVideoStreamViewController()
        })
    }
}

extension LiveStreamingViewModel {

    func didTransitionToLiveStatus() {
        self.liveViewController.showCurrentStatus(currStatus: "● LIVE")
    }

    func didTransitionToStatus(broadcastStatus: String?, streamStatus: String?, healthStatus: String?) {
        if let broadcastStatus = broadcastStatus, let streamStatus = streamStatus, let healthStatus = healthStatus {
            let text = "status: \(broadcastStatus) [\(streamStatus);\(healthStatus)]"
            self.liveViewController.showCurrentStatus(currStatus: text)
        }
    }
}
