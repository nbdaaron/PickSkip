//
//  PreviewView.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/11/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIImageView {

    var playerLayer: AVPlayerLayer?
    var repeatObserver: NSObjectProtocol?
    
    func displayVideo(_ player: AVPlayer) {
        removeExistingContent()
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = bounds
        playerLayer!.videoGravity = AVLayerVideoGravityResize
        layer.addSublayer(playerLayer!)
        
        playOnRepeat(player)
    }
    
    func displayImage(_ image: UIImage) {
        removeExistingContent()
        
        self.image = image
    }
    
    private func playOnRepeat(_ player: AVPlayer) {
        player.play()
        
        repeatObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        })
    }
    
    private func removeExistingContent() {
        image = nil
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(repeatObserver as Any)
    }

}
