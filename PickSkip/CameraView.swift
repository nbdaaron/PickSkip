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
    func submit(videoURL: URL)
    func showSettings()
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
    
    ///This method is called when the Camera View Controller is created.
    public func setupCameraView(_ recordButton: RecordButton) {
        //Add Camera Button
        self.recordButton = recordButton
        createCaptureSession()
        preparePreviewLayer()
        addSwitchCameraGestureRecognizer()
        setupRecordButton()
        
        captureSession.startRunning()
    }
    
    
    ///Creates the Capture Session, connecting the camera and the microphone as the input, and linking the output to AVCapturePhotoOutput and AVCaptureMovieFileOutput instances
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
            } else { //Assume otherwise the default camera is the back camera.
                captureSession.addInput(backCameraInput)
            }
            captureSession.addInput(microphoneInput)
        } catch {
            print("Error creating input devices (from CameraView#createCaptureSession): \(error)")
        }
    }
    
    ///Prepares and adds the Preview Layer so the camera display is visible while recording.
    private func preparePreviewLayer() {
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            //Resize Aspect Fill: Scale Video to edges of screen but do not distort image.
            previewLayer.videoGravity = Constants.videoGravity
            previewLayer.frame = self.frame
            
            //Index 0 is behind all other layers.
            layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    ///Adds the gesture recognizer (recognizing double taps on the camera view) which switches between front and back camera
    private func addSwitchCameraGestureRecognizer() {
        let switchCameraRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapScreen))
        switchCameraRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(switchCameraRecognizer)
    }
    
    ///Prepares the record button with its corresponding gesture recognizers (tap to take photo, hold to record video). Also links the button to this instance as delegate to be notified when the record button has reached max progress.
    private func setupRecordButton() {
        recordButton.delegate = self
        
        let recordRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didHoldRecordButton))
        recordButton.addGestureRecognizer(recordRecognizer)
        let photoRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapRecordButton))
        recordButton.addGestureRecognizer(photoRecognizer)
    }

    
    public func flipCamera() {
        let input = getCameraType()
        self.captureSession.beginConfiguration()
        if input == backCameraInput {
            captureSession.removeInput(backCameraInput)
            captureSession.addInput(frontCameraInput)
        } else if input == frontCameraInput {
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(backCameraInput)
        } else {
            print("No camera found from CameraView#didDoubleTapScreen!!!")
        }
        captureSession.commitConfiguration()
    }
    
    ///This method is called when the double-tap gesture recognizer recognizes the action. It switches the capture session between front and back cameras.
    public func didDoubleTapScreen(gesture: UIGestureRecognizer) {
        let input = getCameraType()
        self.captureSession.beginConfiguration()
        if input == backCameraInput {
            captureSession.removeInput(backCameraInput)
            captureSession.addInput(frontCameraInput)
        } else if input == frontCameraInput {
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(backCameraInput)
        } else {
            print("No camera found from CameraView#didDoubleTapScreen!!!")
        }
        captureSession.commitConfiguration()
    }
    
    ///Returns the current camera type associated with the Capture Session
    public func getCameraType() -> AVCaptureDeviceInput? {
        let inputs = captureSession.inputs as! [AVCaptureDeviceInput]
        if inputs.contains(backCameraInput) {
            return backCameraInput
        } else if inputs.contains(frontCameraInput) {
            return frontCameraInput
        } else {
            return nil
        }
    }
    
    ///This method is called when the record button is held down and released. The capture layer will start recording and the button will animate. When released, the recording will stop and the video will be sent to the Camera View Delegate
    public func didHoldRecordButton(gesture: UITapGestureRecognizer) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            if gesture.state == .began {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filePath = documentsURL.appendingPathComponent(Constants.videoFileName)
                
                //Fix mirrored videos for front camera.
                if getCameraType() == frontCameraInput {
                    videoOutput.connection(withMediaType: AVMediaTypeVideo).isVideoMirrored = true
                }
                
                videoOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
                recordButton.didTouchDown()
            } else if gesture.state == .ended {
                recordButton.didTouchUp()
                videoOutput.stopRecording()
            }
        } else {
            delegate.showSettings()
        }
        
    }
    
    ///This method is called when the record button is briefly tapped. The capture layer will take a photo and send it to the Camera View Delegate
    public func didTapRecordButton(gesture: UITapGestureRecognizer) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        } else {
            delegate.showSettings()
        }
        
    }
    
    ///Automatically focuses camera at point where tapped.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            let screenSize = bounds.size
            if let touchPoint = touches.first {
                let x = touchPoint.location(in: self).y / screenSize.height
                let y = 1.0 - touchPoint.location(in: self).x / screenSize.width
                let focusPoint = CGPoint(x: x, y: y)
                
                if let device = getCameraType()?.device {
                    do {
                        try device.lockForConfiguration()
                        if device.isFocusModeSupported(Constants.focusMode){
                            device.focusMode = Constants.focusMode
                        }
                        if device.isExposureModeSupported(Constants.exposureMode) {
                            device.exposureMode = Constants.exposureMode
                        }
                        if device.isFocusPointOfInterestSupported {
                            device.focusPointOfInterest = focusPoint
                        }
                        if device.isExposurePointOfInterestSupported {
                            device.exposurePointOfInterest = focusPoint
                        }
                        device.unlockForConfiguration()
                    }
                    catch {
                        print("Error focusing camera on CameraView#touchesBegan: \(error)")
                    }
                }
            }
        } else {
            delegate.showSettings()
        }
        
    }

}

///This class implements AVCapturePhotoCaptureDelegate so it can handle the photos that are taken.
extension CameraView: AVCapturePhotoCaptureDelegate {
    
    ///Upon photo capture, renders the image in a UIImageView and submit it to the Camera View Delegate.
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        let dataProvider = CGDataProvider(data: imageData! as CFData)
        
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        
        if getCameraType() == frontCameraInput {
            //Fixed mirrored videos for back camera.
            delegate.submit(image: UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .leftMirrored))
        } else {
            //Otherwise just submit regular image.
            delegate.submit(image: UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right))
        }
        
    }
}

//This class implements AVCaptureFileOutputRecordingDelegate so it can handle the videos that are recorded.
extension CameraView: AVCaptureFileOutputRecordingDelegate {
    
    ///Upon recording video, renders the video in an AVPlayer and submit it to the Camera View Delegate.
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if error != nil {
            print("Error Recording from CameraView:AVCaptureFileOutputRecordingDelegate#capture: \(error.localizedDescription)")
        } else {
            
            delegate.submit(videoURL: outputFileURL)
            
        }
    }
}

//This class implements RecordDelegate so it is notified when the Record Button reaches its max progress
extension CameraView: RecordDelegate {
    func maxRecordProgressReached() {
        videoOutput.stopRecording()
    }
}
