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
    
    var thumbnail: ThumbnailView = {
        let imageView = ThumbnailView()
        imageView.layer.borderColor = UIColor(colorLiteralRed: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0).cgColor
        imageView.layer.borderWidth = 1.5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        return imageView
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
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
    
    func loadAnimation() {
        self.layer.borderWidth = 1.0
        let color = CABasicAnimation(keyPath: "borderColor")
        color.fromValue = UIColor.clear.cgColor
        color.toValue = UIColor.gray.cgColor
        color.duration = 1
        color.repeatCount = Float.infinity
        color.autoreverses = true
        self.layer.add(color, forKey: "color")
    }
    
    func cancelAnimation() {
        self.dateLabel.font = UIFont(name: "Raleway-SemiBold", size: 20)
        self.nameLabel.font = UIFont(name: "Raleway-SemiBold", size: 20)
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.removeAllAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
