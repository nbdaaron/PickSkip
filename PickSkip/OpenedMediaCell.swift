//
//  UnopenedMediaCell.swift
//  PickSkip
//
//  Created by Eric Duong on 8/2/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import UIKit

class OpenedMediaCell: UITableViewCell {
    
    var media: Media!

    
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: Constants.defaultFont, size: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Placeholder"
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.font = UIFont(name: Constants.defaultFont, size: 40)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        label.text = "January 20, 2017 \n 11:15 PM"
        return label
    }()
    
    var thumbnail: TestView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        self.backgroundColor = .white
        
        thumbnail = TestView()
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(thumbnail)
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
        self.addSubview(thumbnail)
        setContraints()
        
    }
    
    func setContraints() {
        let constraints = [
            thumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.bounds.height * 0.8 / 2),
            thumbnail.topAnchor.constraint(equalTo: self.topAnchor, constant: 3.0),
            thumbnail.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3.0),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0),
            dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15.0),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10.0),
            dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -self.bounds.height * 0.8 / 2)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
//    func loadAnimation() {
//        self.layer.borderWidth = 1.0
//        let color = CABasicAnimation(keyPath: "borderColor")
//        color.fromValue = UIColor.clear.cgColor
//        color.toValue = UIColor.gray.cgColor
//        color.duration = 1
//        color.repeatCount = Float.infinity
//        color.autoreverses = true
//        self.layer.add(color, forKey: "color")
//    }
    
    func loadAnimation() {
        let borderDraw = CABasicAnimation(keyPath: "strokeEnd")
        borderDraw.fromValue = 0
        borderDraw.toValue = 1
        borderDraw.duration = 1
        borderDraw.beginTime = 1
        borderDraw.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let borderErase = CABasicAnimation(keyPath: "strokeEnd")
        
        borderErase.fromValue = 1
        borderErase.toValue = 0
        borderErase.duration = 1
        borderErase.beginTime = 0
        borderErase.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        
        let animationGroup = CAAnimationGroup()
        animationGroup.repeatCount = Float.infinity
        animationGroup.duration = 2
        
        animationGroup.animations = [borderErase, borderDraw]
        thumbnail.circleLayer.add(animationGroup, forKey: "borderAnimations")
    }
    
    func cancelAnimation() {
        self.dateLabel.textColor = UIColor(colorLiteralRed: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)

        self.nameLabel.textColor = UIColor(colorLiteralRed: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)

        thumbnail.circleLayer.removeAllAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

class TestView: UIView {
    var circleLayer: CAShapeLayer!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        circleLayer = CAShapeLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView = UIImageView()
        circleLayer = CAShapeLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clear
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0), radius: (frame.size.width - 5)/2, startAngle: 0.0, endAngle: CGFloat(.pi * 2.0), clockwise: false)
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(colorLiteralRed: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0).cgColor
        circleLayer.lineWidth = 2.0;
        circleLayer.strokeEnd = 1.0
        

        layer.addSublayer(circleLayer)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width * 0.8, height: self.frame.height * 0.8)
        imageView.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = (frame.size.width * 0.8)/2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
    }
}

class ThumbnailView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
    }
}

private class customView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
}
