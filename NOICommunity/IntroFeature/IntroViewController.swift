//
//  IntroViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/10/21.
//

import UIKit
import AVKit

class IntroViewController: UIViewController {

    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        let videoURL = Bundle.main.url(
            forResource: "NOI_begins-with-you_Animation_black_short",
            withExtension: "mp4"
        )!

        // Init video
        player = AVPlayer(url: videoURL)
        self.player?.isMuted = true
        self.player?.actionAtItemEnd = .none

        // Add player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = view.frame

        // Add video layer
        self.videoView.layer.addSublayer(playerLayer)

        // Play video
        self.player?.play()
    }
}
