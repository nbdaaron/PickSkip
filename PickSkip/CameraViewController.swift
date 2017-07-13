//
//  CameraViewController.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/10/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var recordButton: RecordButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up Camera View
        cameraView.delegate = self
        cameraView.setupCameraView(recordButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Display the preview layer - called after a photo/video submission is received.
    func displayPreview() {
        previewView.isHidden = false
        optionsView.isHidden = false
    }
    
    //Hide the preview layer - called when the 'X' button is tapped from the options view.
    @IBAction func closePreview(_ sender: Any) {
        previewView.removeExistingContent()
        previewView.isHidden = true
        optionsView.isHidden = true
    }

}

extension CameraViewController: CameraViewDelegate {
    
    //Accepts an image, displays it on the PreviewView.
    func submit(image: UIImage) {
        displayPreview()
        previewView.displayImage(image)
    }
    
    //Accepts a video, displays it on the PreviewView.
    func submit(video: AVPlayer) {
        displayPreview()
        previewView.displayVideo(video)
    }
}
