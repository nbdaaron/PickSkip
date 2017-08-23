//
//  UnopenedMediaCell.swift
//  PickSkip
//
//  Created by Eric Duong on 8/2/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import UIKit

class UnopenedMediaCell: UITableViewCell {
    
    var media: Media!
    
    
    var cellFrame: CellFrameView = {
        let view = CellFrameView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        label.font = UIFont(name: Constants.defaultFont, size: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = ""
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white
        self.addSubview(cellFrame)
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
        setContraints()
    }
    
    func setContraints() {
        let constraints = [
            cellFrame.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cellFrame.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            cellFrame.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            cellFrame.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.97),
            nameLabel.leadingAnchor.constraint(equalTo: cellFrame.leadingAnchor, constant: self.bounds.height * 0.8 / 2),
            nameLabel.topAnchor.constraint(equalTo: cellFrame.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: cellFrame.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalTo: cellFrame.widthAnchor, multiplier: 0.5),
            dateLabel.topAnchor.constraint(equalTo: cellFrame.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: cellFrame.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: cellFrame.trailingAnchor,constant: -self.bounds.height * 0.8 / 2)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }
    
    func shake() {
        let duration: CFTimeInterval = 0.3
        let pathLength: CGFloat = 10
        let position: CGPoint = self.center
        
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: position.x, y: position.y))
        path.addLine(to: CGPoint(x: position.x-pathLength,y: position.y))
        path.addLine(to: CGPoint(x: position.x+pathLength,y: position.y))
        path.addLine(to: CGPoint(x: position.x-pathLength,y: position.y))
        path.addLine(to: CGPoint(x: position.x+pathLength,y: position.y))
        path.addLine(to: CGPoint(x: position.x,y: position.y))
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        
        positionAnimation.path = path.cgPath
        positionAnimation.duration = duration
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        CATransaction.begin()
        self.layer.add(positionAnimation, forKey: nil)
        CATransaction.commit()
    }
    
    func loadAnimation() {
        let color = CABasicAnimation(keyPath: "borderColor")
        color.fromValue = UIColor.clear.cgColor
        color.toValue = UIColor.gray.cgColor
        color.duration = 1
        color.repeatCount = Float.infinity
        color.autoreverses = true
        self.cellFrame.layer.add(color, forKey: "color")
    }
    
    func cancelAnimation() {
        self.dateLabel.textColor = .black
        self.nameLabel.textColor = .black
        self.cellFrame.layer.borderWidth = 1.0
        self.cellFrame.layer.borderColor = UIColor.black.cgColor
        self.cellFrame.layer.removeAllAnimations()
    }
    
}

