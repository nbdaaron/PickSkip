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
    
    var cellFrame: customView = {
        let view = customView()
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
        label.font = UIFont(name: Constants.defaultFont, size: 15)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = "January 20, 2017"
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.addSubview(cellFrame)
        self.addSubview(nameLabel)
        //self.addSubview(dateLabel)
        setContraints()
        
    }
    
    func setContraints() {
        let constraints = [
            cellFrame.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cellFrame.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            cellFrame.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            cellFrame.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
            nameLabel.leadingAnchor.constraint(equalTo: cellFrame.leadingAnchor, constant: self.bounds.height * 0.8 / 2),
            nameLabel.topAnchor.constraint(equalTo: cellFrame.topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: cellFrame.bottomAnchor),
            nameLabel.widthAnchor.constraint(equalTo: cellFrame.widthAnchor, multiplier: 0.5),
//            dateLabel.topAnchor.constraint(equalTo: cellFrame.topAnchor),
//            dateLabel.bottomAnchor.constraint(equalTo: cellFrame.bottomAnchor),
//            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
//            dateLabel.trailingAnchor.constraint(equalTo: cellFrame.trailingAnchor,constant: -self.bounds.height * 0.8 / 2)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }
    
    
    
}

class customView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
            self.layer.cornerRadius = self.bounds.height / 2
    }
}
