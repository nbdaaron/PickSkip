//
//  ContactCell.swift
//  PickSkip
//
//  Created by Eric Duong on 7/13/17.
//
//

import Foundation
import UIKit

class ContactCell: UITableViewCell {
    
    var selectedIndicator = UIView()
    
    var state = false
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isUserInteractionEnabled = true
        textLabel?.frame = CGRect( x: 15, y: 0, width: 300, height: self.frame.height)
        textLabel?.font = UIFont(name: "Raleway-Light", size: 20)
        textLabel?.isUserInteractionEnabled = false
        backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        textLabel?.textColor = .white
        
        let dotSize = self.frame.height / 2
        selectedIndicator.frame = CGRect (x: self.frame.width - dotSize * 2, y: self.frame.height / 2 - dotSize / 2, width: dotSize, height: dotSize)
            selectedIndicator.backgroundColor = .white
        
        selectedIndicator.layer.cornerRadius = dotSize / 2
        selectedIndicator.isUserInteractionEnabled = false
        self.contentView.addSubview(selectedIndicator)
        
        //let contraints = [
        //    selectedIndicator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        //    selectedIndicator.topAnchor.constraint(equalTo: self.topAnchor),
        //    selectedIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        //    selectedIndicator.widthAnchor.constraint(equalToConstant: 50)
        //]
        //NSLayoutConstraint.activate(contraints)
        
    }

    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        //addSubview(selectedIndicator)
        
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
//        let dotSize = self.frame.height / 2
//            let selectedIndicator = UIView()
//            selectedIndicator.frame = CGRect (x: self.frame.width - dotSize * 2, y: self.frame.height / 2 - dotSize / 2, width: dotSize, height: dotSize)
//            selectedIndicator.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
//            selectedIndicator.layer.cornerRadius = dotSize / 2
//        self.contentView.addSubview(selectedIndicator)
        if !(state) {
            selectedIndicator.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
        } else {
            selectedIndicator.backgroundColor = .white
        }
        state = state ? false : true
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
