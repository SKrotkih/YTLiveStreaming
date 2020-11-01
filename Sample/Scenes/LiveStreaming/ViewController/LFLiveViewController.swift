//
//  LFLiveViewController.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 11/8/16.
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
        startLiveButton.isSelected.toggle()
        if startLiveButton.isSelected {
            startPublishing()
        } else {
            stopPublishing()
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        viewModel.didUserCancelPublishingVideo()
    }
    
    func showCurrentStatus(currStatus: String) {
        currentStatusLabel.text = currStatus
    }
    
    private func startPublishing() {
        startLiveButton.setTitle("Finish live broadcast", for: .normal)
        viewModel.willStartPublishing { streamUrl, scheduledStartTime in
            self.scheduledStartTime = scheduledStartTime
            self.lfView.startPublishing(withStreamURL: streamUrl)
        }
    }

    private func stopPublishing() {
        startLiveButton.setTitle("Start live broadcast", for: .normal)
        lfView.stopPublishing()
        viewModel.finishPublishing()
    }
    
    private func configureView() {
        beautyButton.isExclusiveTouch = true
        cameraButton.isExclusiveTouch = true
        closeButton.isExclusiveTouch = true
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
                DispatchQueue.performUIUpdate { [weak self] in
                    self?.showCurrentStatus(currStatus: state)
                }
            }).disposed(by: disposeBag)
    }
}
