//
//  VideoPlayerViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

class VideoPlayerViewController: UIViewController {

    var interactor: VideoPlayerInteractor!

    @IBOutlet weak var playerView: UIView!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var forvardButton: UIButton!

    @IBOutlet weak var slider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        playerView.addSubview(interactor.videoPlayer.playerView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        interactor.videoPlayer.playerView.frame = playerView.bounds
    }

    @IBAction func onPressButton(_ sender: Any) {
        switch sender as! UIButton {
        case playButton:
            interactor.play()
        case pauseButton:
            interactor.pause()
        case stopButton:
            interactor.stop()
        case startButton:
            interactor.start()
        case reverseButton:
            interactor.reverse()
        case forvardButton:
            interactor.forward()
        default:
            break
        }
    }

    @IBAction func onSliderChange(_ sender: Any) {
        interactor.seekToSeconds(self.slider.value)
    }

    @IBAction func onCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
