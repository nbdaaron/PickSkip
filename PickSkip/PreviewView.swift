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
    
    //Accepts a video and play it on repeat.
    func displayVideo(_ player: AVPlayer) {
        removeExistingContent()
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = bounds
        playerLayer!.videoGravity = Constants.videoGravity
        layer.addSublayer(playerLayer!)
        
        playOnRepeat(player)
    }
    
    //Accepts an image and display it.
    func displayImage(_ image: UIImage) {
        removeExistingContent()
        
        self.image = image
    }
    
    //Plays the video and set up a notification that will play the video again when completed.
    private func playOnRepeat(_ player: AVPlayer) {
        player.play()
        
        repeatObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                player.seek(to: kCMTimeZero)
                player.play()
            }
        })
    }
    
    //This function is called when displaying a new photo or image. Clears any existing content being displayed.
    func removeExistingContent() {
        image = nil
        playerLayer?.player?.pause()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(repeatObserver as Any)
    }

}
