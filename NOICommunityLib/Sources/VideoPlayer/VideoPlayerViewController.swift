//
//  File.swift
//  
//
//  Created by Camilla on 23/12/24.
//

import Foundation
import AVKit

public class VideoPlayerViewController: AVPlayerViewController {
    
    public init(videoURL: URL) {
        super.init(nibName: nil, bundle: nil)
        let player = AVPlayer(url: videoURL)
        self.player = player
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        player?.play()
    }
}
