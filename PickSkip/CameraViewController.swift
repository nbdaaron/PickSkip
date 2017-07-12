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
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayPreview() {
        previewView.isHidden = false
        optionsView.isHidden = false
    }
    
    @IBAction func closePreview(_ sender: Any) {
        previewView.isHidden = true
        optionsView.isHidden = true
    }

}

extension CameraViewController: CameraViewDelegate {
    func submit(image: UIImage) {
        displayPreview()
        previewView.displayImage(image)
    }
    
    func submit(video: AVPlayer) {
        displayPreview()
        previewView.displayVideo(video)
    }
}
