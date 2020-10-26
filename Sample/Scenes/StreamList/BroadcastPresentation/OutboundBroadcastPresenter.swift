//
//  OutboundBroadcastPresenter.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming

class OutboundBroadcastPresenter: NSObject {

    // Dependebcies
    var interactor: InboundBroadcastPresenter!
    weak var liveViewController: LFLiveViewController!
    var outgoingBroadcastWorker: YTLiveStreaming!

    fileprivate var liveBroadcast: LiveBroadcastStreamModel?
}

// MARK: -

extension OutboundBroadcastPresenter {

    func createBroadcast(_ completion: @escaping (Error?) -> Void) {
        interactor.createBroadcast(completion)
    }

    private func startBroadcast(_ liveBroadcast: LiveBroadcastStreamModel) {
        self.liveBroadcast = liveBroadcast

        print("Watch the live video: https://www.youtube.com/watch?v=\(liveBroadcast.id)")

        AppDelegate.shared.appRouter.showLiveVideoViewController()
    }

    fileprivate func dismissVideoStreamViewController() {
        DispatchQueue.main.async {
            self.liveViewController.dismiss(animated: true, completion: {
            })
        }
    }
}

// MARK: Live stream publishing output protocol

extension OutboundBroadcastPresenter: YouTubeLiveVideoOutput {

    func startPublishing(completed: @escaping (String?, String?) -> Void) {
        guard let broadcast = self.liveBroadcast else {
            assert(false, "Need Broadcast object for starting live video!")
            return
        }
        guard let delegate = self as? LiveStreamTransitioning else {
            return
        }
        outgoingBroadcastWorker.startBroadcast(broadcast,
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
        outgoingBroadcastWorker.completeBroadcast(broadcast, completion: { _ in
            self.dismissVideoStreamViewController()
        })
    }

    func cancelPublishing() {
        guard let broadcast = self.liveBroadcast else {
            self.dismissVideoStreamViewController()
            return
        }
        outgoingBroadcastWorker.deleteBroadcast(id: broadcast.id, completion: { success in
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

extension OutboundBroadcastPresenter {

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
