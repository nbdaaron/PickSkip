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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
        setContraints()
        
    }
    
    func setContraints() {
        let constraints = [
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.bounds.height * 0.8 / 2),
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0),
            dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15.0),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10.0),
            dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -self.bounds.height * 0.8 / 2)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }
    
    
    
}

private class customView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
}
