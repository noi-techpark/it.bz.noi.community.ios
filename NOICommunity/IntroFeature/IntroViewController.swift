// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  IntroViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/10/21.
//

import UIKit
import AVKit

final class IntroViewController: UIViewController {

    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!

    var didFinishHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .noiBackgroundColor

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
        let edge = min(view.frame.width, view.frame.height)
        playerLayer.frame = CGRect(
            x: (view.frame.width - edge) / 2,
            y: (view.frame.height - edge) / 2,
            width: edge,
            height: edge
        )

        // Add video layer
        view.layer.addSublayer(playerLayer)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        // Play video
        enableAudioMix()
        player.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let edge = min(view.frame.width, view.frame.height)
        playerLayer.frame = CGRect(
            x: (view.frame.width - edge) / 2,
            y: (view.frame.height - edge) / 2,
            width: edge,
            height: edge
        )
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}

// MARK: Private APIs

private extension IntroViewController {
    @objc func playerDidFinishPlaying(_ notification: NSNotification) {
        didFinishHandler?()
        disableAudioMix()
    }

    func enableAudioMix() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback,
                                    mode: .default,
                                    options: [.mixWithOthers]
            )
            try session.setActive(true)
        } catch {
            print(error)
        }
    }

    func disableAudioMix() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback,
                                    mode: .default,
                                    options: [.mixWithOthers]
            )
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
    }
}
