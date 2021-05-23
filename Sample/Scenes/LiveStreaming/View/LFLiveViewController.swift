//
//  LFLiveViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 11/8/16.
//

import UIKit
import RxSwift
import YTLiveStreaming

class LFLiveViewController: UIViewController {
    var viewModel: YouTubeLiveVideoPublisher!

    var scheduledStartTime: NSDate?

    @IBOutlet weak var lfView: LFLivePreview!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startLiveButton: UIButton!
    @IBOutlet weak var currentStatusLabel: UILabel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        lfView.prepareForUsing()
        startListeningToModelEvents()
    }

    @IBAction func changeCameraPositionButtonPressed(_ sender: Any) {
        lfView.changeCameraPosition()
    }

    @IBAction func changeBeautyButtonPressed(_ sender: Any) {
        beautyButton.isSelected = lfView.changeBeauty()
    }

    @IBAction func onClickPublish(_ sender: Any) {
        handleClickOnPublishingButton()
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        viewModel.didUserCancelPublishingVideo()
    }

    func showCurrentStatus(currStatus: String) {
        DispatchQueue.performUIUpdate { [weak self] in
            self?.currentStatusLabel.text = currStatus
        }
    }

    func showError(_ message: String) {
        DispatchQueue.performUIUpdate {
            Alert.showOk("Warning", message: message)
        }
    }

    private func handleClickOnPublishingButton() {
        isVideoInProcess.toggle()
        if isVideoInProcess {
            startPublishing()
        } else {
            stopPublishing()
        }
    }

    private var isVideoInProcess: Bool = false {
        didSet {
            startLiveButton.isSelected = isVideoInProcess
            startLiveButton.setTitle(isVideoInProcess ? "Finish live broadcast" : "Start live broadcast", for: .normal)
        }
    }

    private func startPublishing() {
        viewModel.willStartPublishing { streamUrl, scheduledStartTime in
            self.scheduledStartTime = scheduledStartTime
            self.lfView.startPublishing(withStreamURL: streamUrl)
        }
    }

    private func stopPublishing() {
        lfView.stopPublishing()
        viewModel.finishPublishing()
    }

    private func configureView() {
        beautyButton.isExclusiveTouch = true
        cameraButton.isExclusiveTouch = true
        closeButton.isExclusiveTouch = true
        isVideoInProcess = false
    }

    private func startListeningToModelEvents() {
        viewModel
            .rxDidUserFinishWatchVideo
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.performUIUpdate { [weak self] in
                    self?.dismiss(animated: true, completion: {
                    })
                }
            }).disposed(by: disposeBag)
        viewModel
            .rxStateDescription
            .subscribe(onNext: { [weak self] state in
                self?.showCurrentStatus(currStatus: state)
            }).disposed(by: disposeBag)
        viewModel
            .rxError
            .subscribe(onNext: { [weak self] message in
                self?.showError(message)
            }).disposed(by: disposeBag)
    }
}
