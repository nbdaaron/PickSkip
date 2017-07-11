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

class Constants {

    //Maximum allowed recorded video duration in seconds
    static let maxVideoDuration: CGFloat = 5
    
    //Seconds per frame for recording button animation
    static let updateInterval: Double = 0.05
    
    //The default camera loaded when the application is opened.
    static let defaultCamera: AVCaptureDevice = backCamera

    
    //The constants above may be modified to modify application functionality. Please do not alter the constants below.
    
    static let backCamera: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)

    static let frontCamera: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)

    static let microphone: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
}
