//
//  IntroViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/10/21.
//

import UIKit
import AVKit

final class IntroViewController: UIViewController {

    @IBOutlet private var playerContainerView: UIView!
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!

    var didFinishHandler: (() -> Void)?

    init() {
        super.init(nibName: "\(IntroViewController.self)", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let videoURL = Bundle.main.url(
            forResource: "NOI_begins-with-you_Animation_black_short",
            withExtension: "mp4"
        )!

        // Init video
        player = AVPlayer(url: videoURL)
        player.isMuted = true
        player.actionAtItemEnd = .none

        // Add player layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = playerContainerView.bounds

        // Add video layer
        playerContainerView.layer.addSublayer(playerLayer)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        // Play video
        player.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        playerLayer.frame = playerContainerView.bounds
    }
}

// MARK: Private APIs

private extension IntroViewController {
    @objc func playerDidFinishPlaying(_ notification: NSNotification) {
        didFinishHandler?()
    }
}
