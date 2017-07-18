//
//  counterButton.swift
//  PickSkip
//
//  Created by Eric Duong on 7/11/17.
//
//

import Foundation
import UIKit

class CounterButton : UIButton {
    
    var count = 0
    var type : String!
    
    fileprivate var buttonBorder : CALayer!
    fileprivate var buttonLabel : CATextLayer!
    
    
    public init(buttonType: String, frame: CGRect){
        super.init(frame: frame)
        type = buttonType
        
        setupButton()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        
        setupButton()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton() {
        self.backgroundColor = UIColor(colorLiteralRed: 22.0/255.0, green: 222.0/255.0, blue: 238.0/255.0, alpha: 1)
        layer.cornerRadius = self.frame.height / 5
        layer.borderWidth = 0
        translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "Raleway-Light", size: self.frame.height / 3)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
//        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
//        self.addGestureRecognizer(tapGesture)
//        self.addGestureRecognizer(longTapGesture)
        
    }
//    
//    func tapGesture(gesture: UITapGestureRecognizer) {
//        self.count += 1
//        self.setTitle(String(self.count) + "\n" + self.type, for: .normal)
//    }
//    
//    func longTapGesture(gesture: UILongPressGestureRecognizer){
//        self.count = 0
//        self.setTitle(String(self.count) + "\n" + self.type, for: .normal)
//    }
  
    
    

    
    
    
}
