//
//  Constants.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/11/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import Firebase

class Constants {
    
    //TODO: lower this...
    ///Maximum allowed download size for any content in bytes.
    static let maxDownloadSize: Int64 = 1073741824 //2^30 bytes = 1GB

    ///Maximum allowed recorded video duration in seconds
    static let maxVideoDuration: CGFloat = 5
    
    ///Seconds per frame for recording button animation
    static let updateInterval: Double = 0.05
    
    ///The default camera loaded when the application is opened.
    static let defaultCamera: AVCaptureDevice = backCamera
    
    ///The following storyboard IDs are used to create the Main Pages scroll view.
    static let mainPagesViews: [String] = ["HistoryTableViewController", "CameraViewController"]
    
    ///Temporary file name for recorded videos
    static let videoFileName: String = "temp.mp4"

    ///Default camera/playback video gravity (determines how to stretch/distort images to fit in screen)
    static let videoGravity: String = AVLayerVideoGravityResize
    
    ///Default camera focusing mode
    static let focusMode: AVCaptureFocusMode = .autoFocus
    
    ///Default camera exposure mode
    static let exposureMode: AVCaptureExposureMode = .continuousAutoExposure
    
    ///The constants above may be modified to modify application functionality. Please do not alter the constants below.
    
    static let backCamera: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)

    static let frontCamera: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)

    static let microphone: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    
    ///Adds and saves Login Listener on any view controller. Should be called from viewWillAppear. Will send to Login Page if user is not logged in.
    static func addLoginCheckListener(_ vc: UIViewController) {
        currentLoginCheckListener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                let loginViewController = vc.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                vc.present(loginViewController, animated: true, completion: nil)
            } else {
                
            }
        }
    }
    
    ///Removes the current Login Listener. Should be called from viewWillDisappear.
    static func removeCurrentLoginCheckListener() {
        currentLoginCheckListener = nil
    }
    
    ///The current Login Listener. If updated, the original listener will be removed.
    static var currentLoginCheckListener: AuthStateDidChangeListenerHandle? {
        willSet {
            if let listener = currentLoginCheckListener {
                Auth.auth().removeStateDidChangeListener(listener)
            }
        }
    }
}
