//
//  CameraViewController.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/10/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase


class CameraViewController: UIViewController {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var recordButton: RecordButton!
    
    var image: UIImage!
    var video: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up Camera View
        
        cameraView.delegate = self
        cameraView.setupCameraView(recordButton)
        
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPreview" {
            let destination = segue.destination as? PreviewController
            if let image = image {
                destination?.image = image
                print("sent pic")
                self.image = nil
            } else if let video = video {
                destination?.video = video
                print("sent vid")
                self.video = nil
            }
        }
        
    }
}

extension CameraViewController: CameraViewDelegate {
    
    ///Accepts an image, displays it on the PreviewView.
    func submit(image: UIImage) {
        self.image = image
        self.performSegue(withIdentifier: "showPreview", sender: self)
    }
    
    ///Accepts a video, displays it on the PreviewView.
    func submit(videoURL: URL) {
        self.video = videoURL
        self.performSegue(withIdentifier: "showPreview", sender: self)
    }
}
