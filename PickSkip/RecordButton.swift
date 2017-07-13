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
    
    var buttonColor: UIColor! = .white{
        didSet {
            circleBorder.borderColor = buttonColor.cgColor
        }
    }
    
    var progressColor: UIColor!  = .red {
        didSet {
            gradientMaskLayer.colors = [progressColor.cgColor, progressColor.cgColor]
        }
    }
    
    open var closeWhenFinished: Bool = false
    
    open var buttonState : RecordButtonState = .idle {
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
    
    fileprivate var circleLayer: CALayer!
    fileprivate var circleBorder: CALayer!
    fileprivate var progressLayer: CAShapeLayer!
    fileprivate var gradientMaskLayer: CAGradientLayer!
    fileprivate var currentProgress: CGFloat! = 0
    fileprivate var circleBorder2: CALayer!
    
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
        
        let startAngle: CGFloat = CGFloat(Double.pi) + CGFloat(Double.pi / 2)
        let endAngle: CGFloat = CGFloat(Double.pi) * 3 + CGFloat(Double.pi / 2)
        let centerPoint: CGPoint = CGPoint(x: self.frame.size.width / 2 + 15 , y: self.frame.size.height / 2 + 15)
        gradientMaskLayer = self.gradientMask()
        progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width * 0.585 , startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = 7.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        gradientMaskLayer.mask = progressLayer
        layer.insertSublayer(gradientMaskLayer, at: 1)
    }
    
    func setRecording(_ recording: Bool) {
        
        let duration: TimeInterval = 0.15
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = recording ? 1.0 : 1.3
        scale.toValue = recording ? 1.3 : 1
        scale.duration = duration
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        
        let color = CABasicAnimation(keyPath: "backgroundColor")
        color.duration = duration
        color.fillMode = kCAFillModeForwards
        color.isRemovedOnCompletion = false
        color.toValue = recording ? progressColor.cgColor : buttonColor.cgColor
        
        
        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        borderScale.fromValue = recording ? 1.0 : 1.3
        borderScale.toValue = recording ? 1.3 : 1.0
        borderScale.duration = duration
        borderScale.fillMode = kCAFillModeForwards
        borderScale.isRemovedOnCompletion = false
        
        let borderAnimations = CAAnimationGroup()
        borderAnimations.isRemovedOnCompletion = false
        borderAnimations.fillMode = kCAFillModeForwards
        borderAnimations.duration = duration
        borderAnimations.animations = [borderScale]
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = recording ? 0.0 : 1.0
        fade.toValue = recording ? 1.0 : 0.0
        fade.duration = duration
        fade.fillMode = kCAFillModeForwards
        fade.isRemovedOnCompletion = false
        
        progressLayer.add(fade, forKey: "fade")
        circleBorder.add(borderAnimations, forKey: "borderAnimations")
        
    }
    
    func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: -15, y: -15, width: self.bounds.width * 1.5, height: self.bounds.height * 1.5)
        //        gradientLayer.bounds = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradientLayer.locations = [0.0, 1.0]
        let topColor = progressColor
        let bottomColor = progressColor
        gradientLayer.colors = [topColor!.cgColor, bottomColor!.cgColor]
        return gradientLayer
    }
    
    ///This method must be called by the View Controller using it.
    open func didTouchDown(){
        self.buttonState = .recording
    }
    
    ///This method must be called by the View Controller using it.
    open func didTouchUp() {
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
