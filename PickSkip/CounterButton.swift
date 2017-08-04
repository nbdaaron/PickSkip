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
    
    var resetButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "undoButton"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        return button
    } ()
    
    var dateLabel: UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Raleway-Light", size: 25)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.text = "alksdmasdlkma"
        label.backgroundColor = .clear
        return label
    }()

    
    public init(buttonType: String, frame: CGRect){
        super.init(frame: frame)
        
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
        resetButton.tag = self.tag
        self.addSubview(resetButton)

        self.addSubview(dateLabel)
        
        if self.tag == 2 {
            dateLabel.textAlignment = .left
            let constraints = [
                resetButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
                resetButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
                resetButton.heightAnchor.constraint(equalToConstant: 30.0),
                resetButton.widthAnchor.constraint(equalToConstant: 30.0),
                dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
                dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                dateLabel.widthAnchor.constraint(equalToConstant: 100),
                dateLabel.heightAnchor.constraint(equalToConstant: 40)
            ]
            NSLayoutConstraint.activate(constraints)
        } else {
            dateLabel.textAlignment = .right
            let constraints = [
                resetButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
                resetButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
                resetButton.heightAnchor.constraint(equalToConstant: 30.0),
                resetButton.widthAnchor.constraint(equalToConstant: 30.0),
                dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),
                dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                dateLabel.widthAnchor.constraint(equalToConstant: 100),
                dateLabel.heightAnchor.constraint(equalToConstant: 40)
            ]
            
            NSLayoutConstraint.activate(constraints)
        }
        
        
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
        titleLabel?.textAlignment = .center
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.font = UIFont(name: "BebasNeueRegular", size: 40.0)
        layer.borderWidth = 1.3
        layer.borderColor = UIColor.black.cgColor
        updateCounter(to: 0)
    }
    
    func updateCounter(to count: Int) {
        switch self.tag {
        case 1:
            setTitle("\(count)" + "\n" + "hour", for: .normal)
        case 2:
            setTitle("\(count)" + "\n" + "minute", for: .normal)
        case 3:
            setTitle("\(count)" + "\n" + "month", for: .normal)
        case 4:
            setTitle("\(count)" + "\n" + "day", for: .normal)
        case 5:
            setTitle("\(count)" + "\n" + "year", for: .normal)
        default:
            print("error updating buttons")
        }
        flash()
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.1
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 1
        
        layer.add(flash, forKey: nil)
    }

    
    
}
