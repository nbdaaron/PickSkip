//
//  MyButton.swift
//  PickSkip
//
//  Created by Eric Duong on 7/9/17.
//
//

import Foundation
import UIKit

public enum RecordButtonState : Int {
    case recording, idle, hidden;
}

protocol RecordDelegate {
    func maxRecordProgressReached()
}

class RecordButton: UIButton {
    
    var delegate: RecordDelegate!
    var timer: Timer?
    var circleLayer: CALayer!
    var circleBorder: CALayer!
    var progressLayer: CAShapeLayer!
    var currentProgress: CGFloat! = 0
    
    var buttonColor: UIColor! = .white{
        didSet {
            circleBorder.borderColor = buttonColor.cgColor
        }
    }
    
    var closeWhenFinished: Bool = false
    
    var buttonState : RecordButtonState = .idle {
        didSet {
            switch buttonState {
            case .idle:
                self.alpha = 1.0
                currentProgress = 0
                timer?.invalidate()
                setProgress(0)
                setRecording(false)
            case .recording:
                self.alpha = 1.0
                setRecording(true)
                timer = Timer.scheduledTimer(timeInterval: Constants.updateInterval, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            case .hidden:
                self.alpha = 0
            }
        }
        
    }
    
    public func updateProgress(timer: Timer) {
        if progressLayer.strokeEnd >= 1 || buttonState != .recording {
            self.buttonState = .idle
            delegate.maxRecordProgressReached()
        }
        progressLayer.strokeEnd += CGFloat(Constants.updateInterval) / Constants.maxVideoDuration
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)

        
        
        self.drawButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        self.drawButton()
    }
    
    func drawButton() {
        self.backgroundColor = UIColor.clear
        let layer = self.layer
        let size = self.frame.size.width
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 7
        circleBorder.borderColor = buttonColor.cgColor
        circleBorder.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleBorder.cornerRadius = size / 2
        circleBorder.shadowOffset = CGSize(width: 0, height: 2)
        circleBorder.shadowOpacity = 0.5
        layer.insertSublayer(circleBorder, at: 0)
        
        //This is the layer that is drawn ontop of the white border when recording starts
        //I don't know how to match the resized white border exactly with the progress layer
        //This will be a problem if we change the size of the button in which case adjust the marked values for now
        //Todo: debug for occasional red segment that lingers after recording is over
        
        let startAngle: CGFloat = CGFloat(Double.pi) + CGFloat(Double.pi / 2)
        let endAngle: CGFloat = CGFloat(Double.pi) * 3 + CGFloat(Double.pi / 2)
        progressLayer = CAShapeLayer()
        progressLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        progressLayer.path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: circleBorder.frame.width / 2.2 , startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.lineWidth = 7.2 //change if needed
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        layer.insertSublayer(progressLayer, at: 1)
    }
    
    func setRecording(_ recording: Bool) {
        let duration: TimeInterval = 0.15
        
        let progressScale = CABasicAnimation(keyPath: "transform.scale")
        progressScale.fromValue = recording ? 1.0 : 1.28 //change if needed
        progressScale.toValue = recording ? 1.28 : 1.0 //change if needed
        progressScale.duration = duration
        progressScale.fillMode = kCAFillModeForwards
        progressScale.isRemovedOnCompletion = false
        
        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        borderScale.fromValue = recording ? 1.0 : 1.3
        borderScale.toValue = recording ? 1.3 : 1.0
        borderScale.duration = duration
        borderScale.fillMode = kCAFillModeForwards
        borderScale.isRemovedOnCompletion = false
        
        progressLayer.add(progressScale, forKey: "progressAnimation")
        circleBorder.add(borderScale, forKey: "borderAnimation")
        
    }
    
    ///This method must be called by the View Controller using it.
    func didTouchDown(){
        self.buttonState = .recording
    }
    
    ///This method must be called by the View Controller using it.
    func didTouchUp() {
        if(closeWhenFinished) {
            self.setProgress(1)
            UIView.animate(withDuration: 0.3, animations: {
                self.buttonState = .hidden
            }, completion: { completion in
                self.setProgress(0)
                self.currentProgress = 0
            })
        } else {
            self.buttonState = .idle
        }
    }
    
    
    /**
     Set the relative length of the circle border to the specified progress
     
     - parameter newProgress: the relative length, a percentage as float.
     */
    open func setProgress(_ newProgress: CGFloat) {
        progressLayer.strokeEnd = newProgress
    }
    
}
