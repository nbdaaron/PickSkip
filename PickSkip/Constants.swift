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
import Contacts
import PhoneNumberKit

class Constants {
    
    //TODO: lower this...
    
    static var contacts: [CNContact] = []
    
    static let defaultBlueColor: UIColor = UIColor(colorLiteralRed: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    
    static let defaultFont: String = "Raleway-Light"
    
    ///Maximum allowed media to be loaded at once.
    static let loadCount: UInt = 5
    
    ///Maximum allowed download size for any content in bytes.
    static let maxDownloadSize: Int64 = 1073741824 //2^30 bytes = 1GB

    ///Maximum allowed recorded video duration in seconds
    static let maxVideoDuration: CGFloat = 15.0
    
    ///Seconds per frame for recording button animation
    static let updateInterval: Double = 0.05
    
    ///The default camera loaded when the application is opened.
    static let defaultCamera: AVCaptureDevice = backCamera
    
    ///The following storyboard IDs are used to create the Main Pages scroll view.
    static let mainPagesViews: [String] = ["HistoryTableViewController", "CameraViewController"]
    
    ///The initial View Controller to display in the Main Pages scroll view.
    static let initialViewPosition: Int = mainPagesViews.index(of: "CameraViewController")!
    
    ///Temporary file name for recorded videos
    static let videoFileName: String = "temp.mp4"

    ///Default camera/playback video gravity (determines how to stretch/distort images to fit in screen)
    static let videoGravity: String = AVLayerVideoGravityResizeAspectFill
    
    ///Default camera focusing mode
    static let focusMode: AVCaptureFocusMode = .autoFocus
    
    ///Default camera exposure mode
    static let exposureMode: AVCaptureExposureMode = .continuousAutoExposure
    
    ///The constants above may be modified to modify application functionality. Please do not alter the constants below.
    
    static let backCamera: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
    

    static let frontCamera: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)

    static let microphone: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    
}

class CellFrameView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
}



public extension Date {
    
    var month: String  { return Formatter.month.string(from: self) }
    var hour:  String      { return Formatter.hour12.string(from: self) }
    var minute: String     { return Formatter.minute.string(from: self) }
    var amPM: String         { return Formatter.amPM.string(from: self) }
    var year: String {return Formatter.year.string(from: self)}
    var day: String {return Formatter.date.string(from: self)}
    
}

public extension UIView {
    func addBottomBorder(with color: UIColor, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
}

