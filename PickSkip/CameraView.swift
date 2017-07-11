//
//  CameraView.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/10/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class CameraView: UIView {

    var captureSession: AVCaptureSession!
    
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    var microphoneInput: AVCaptureDeviceInput!
    
    var photoOutput: AVCapturePhotoOutput!
    var videoOutput: AVCaptureMovieFileOutput!
    
    //This method is called when the Camera View Controller is created.
    public func setupCameraView() {
        //Add Camera Button
        
        createCaptureSession()
        preparePreviewLayer()
        addSwitchCameraGestureRecognizer()
        
        captureSession.startRunning()
    }
    
    
    //Creates the Capture Session, connecting the camera and the microphone as the input, and linking the output to AVCapturePhotoOutput and AVCaptureMovieFileOutput instances
    private func createCaptureSession() {
        captureSession = AVCaptureSession()
        
        //Creates and links the Photo/Video Output
        photoOutput = AVCapturePhotoOutput()
        videoOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        //Default Frame Rate is High Quality
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        do {
            backCameraInput = try AVCaptureDeviceInput(device: Constants.backCamera)
            frontCameraInput = try AVCaptureDeviceInput(device: Constants.frontCamera)
            microphoneInput = try AVCaptureDeviceInput(device: Constants.microphone)
            if Constants.defaultCamera == Constants.frontCamera {
                captureSession.addInput(frontCameraInput)
            } else { //Assume the default camera is the back camera.
                captureSession.addInput(backCameraInput)
            }
            captureSession.addInput(microphoneInput)
        } catch {
            print("Error creating input devices (from CameraView#createCaptureSession): \(error)")
        }
    }
    
    //Prepares and adds the Preview Layer so the camera display is visible while recording.
    private func preparePreviewLayer() {
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            //Resize Aspect Fill: Scale Video to edges of screen but do not distort image.
            previewLayer.videoGravity = AVLayerVideoGravityResize
            previewLayer.frame = self.frame
            
            //Index 0 is behind all other layers.
            layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    //Adds the gesture recognizer (recognizing double taps on the camera view) which switches between front and back camera
    private func addSwitchCameraGestureRecognizer() {
        let switchCameraRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapScreen))
        switchCameraRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(switchCameraRecognizer)
    }
    
    //This method is called when the double-tap gesture recognizer recognizes the action. It switches the capture session between front and back cameras.
    public func didDoubleTapScreen(gesture: UIGestureRecognizer) {
        let inputs = captureSession.inputs as! [AVCaptureDeviceInput]
        self.captureSession.beginConfiguration()
        if inputs.contains(backCameraInput) {
            captureSession.removeInput(backCameraInput)
            captureSession.addInput(frontCameraInput)
        } else if inputs.contains(frontCameraInput) {
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(backCameraInput)
        } else {
            print("No camera found from CameraView#didDoubleTapScreen!!!")
        }
        captureSession.commitConfiguration()

    }

}
