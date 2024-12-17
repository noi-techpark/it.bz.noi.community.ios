// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  VideoPlayerViewController.swift
//  NOICommunity
//
//  Created by Camilla on 17/12/24.
//

import Foundation
import AVKit

class VideoPlayerViewController: AVPlayerViewController {
    
    init(videoURL: URL) {
        super.init(nibName: nil, bundle: nil)
        let player = AVPlayer(url: videoURL)
        self.player = player
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player?.play()
    }
}
