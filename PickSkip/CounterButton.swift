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
        fatalError()
    }
    
    func setupButton() {
        self.backgroundColor = UIColor(colorLiteralRed: 22.0/255.0, green: 222.0/255.0, blue: 238.0/255.0, alpha: 1)
        layer.cornerRadius = 15
        layer.borderWidth = 0
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        setTitleColor(.white, for: .normal)
        
        if type == "min" {
            setTitle("0" + "\n" + type, for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-Light", size: 20)
        }else {
            setTitle("0" + " " + type, for: .normal)
            titleLabel?.font = UIFont(name: "Raleway-Light", size: 25)
        }
        
    }
    

    
    
    
}
