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

protocol CameraViewDelegate {
    func submit(image: UIImage)
    func submit(video: AVPlayer)
}

class CameraView: UIView {

    var captureSession: AVCaptureSession!
    
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    var microphoneInput: AVCaptureDeviceInput!
    
    var photoOutput: AVCapturePhotoOutput!
    var videoOutput: AVCaptureMovieFileOutput!
    
    var delegate: CameraViewDelegate!
    
    var recordButton: RecordButton!
    
    //This method is called when the Camera View Controller is created.
    public func setupCameraView(_ recordButton: RecordButton) {
        //Add Camera Button
        self.recordButton = recordButton
        
        createCaptureSession()
        preparePreviewLayer()
        addSwitchCameraGestureRecognizer()
        setupRecordButton()
        
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
    
    private func setupRecordButton() {
        let recordRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didHoldRecordButton))
        recordButton.addGestureRecognizer(recordRecognizer)
        let photoRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapRecordButton))
        recordButton.addGestureRecognizer(photoRecognizer)
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
    
    public func didHoldRecordButton(gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsURL.appendingPathComponent(Constants.videoFileName)
            videoOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
            recordButton.didTouchDown()
        } else if gesture.state == .ended {
            recordButton.didTouchUp()
            videoOutput.stopRecording()
        }
    }
    
    public func didTapRecordButton(gesture: UITapGestureRecognizer) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

}

extension CameraView: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        let dataProvider = CGDataProvider(data: imageData! as CFData)
        
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
        
        delegate.submit(image: image)
    }
}

extension CameraView: AVCaptureFileOutputRecordingDelegate {
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if error != nil {
            print("Error Recording from CameraView:AVCaptureFileOutputRecordingDelegate#capture: \(error.localizedDescription)")
        } else {
            let player = AVPlayer(url: outputFileURL)
            
            delegate.submit(video: player)
        }
    }
}
