//
//  headerButtonsView.swift
//  PickSkip
//
//  Created by Eric Duong on 7/12/17.
//
//

import Foundation
import UIKit

class HeaderButtonsView : UIView {
    
    var colorView: UIView!
    var bgColor = UIColor(red: 235/255, green: 96/255, blue: 91/255, alpha: 1)
    var yearButton: CounterButton!
    var monthButton: CounterButton!
    var weekButton: CounterButton!
    var dayButton: CounterButton!
    var hourButton: CounterButton!
    var minButton: CounterButton!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.backgroundColor = .white
        
        colorView = UIView()
        yearButton = CounterButton(buttonType: "year", frame: CGRect())
        monthButton = CounterButton(buttonType: "month", frame: CGRect())
        weekButton = CounterButton(buttonType: "week", frame: CGRect())
        dayButton = CounterButton(buttonType: "day", frame: CGRect())
        hourButton = CounterButton(buttonType: "hour", frame: CGRect())
        minButton = CounterButton(buttonType: "min", frame: CGRect())
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(colorView)
        self.addSubview(yearButton)
        self.addSubview(monthButton)
        self.addSubview(weekButton)
        self.addSubview(dayButton)
        self.addSubview(minButton)
        self.addSubview(hourButton)
        
        let constraints:[NSLayoutConstraint] = [
            colorView.topAnchor.constraint(equalTo: self.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            yearButton.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 15),
            yearButton.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -15),
            yearButton.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 85),
            yearButton.heightAnchor.constraint(equalToConstant: 50),
            
            monthButton.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 15),
            monthButton.widthAnchor.constraint(equalToConstant: 198),
            monthButton.topAnchor.constraint(equalTo: yearButton.bottomAnchor, constant: 20),
            monthButton.heightAnchor.constraint(equalToConstant: 50),
            
            weekButton.leadingAnchor.constraint(equalTo: monthButton.trailingAnchor, constant: 15),
            weekButton.widthAnchor.constraint(equalToConstant: 132),
            weekButton.topAnchor.constraint(equalTo: yearButton.bottomAnchor, constant: 20),
            weekButton.heightAnchor.constraint(equalToConstant: 50),
            
            dayButton.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 15),
            dayButton.widthAnchor.constraint(equalToConstant: 157.5),
            dayButton.topAnchor.constraint(equalTo: monthButton.bottomAnchor, constant: 20),
            dayButton.heightAnchor.constraint(equalToConstant: 50),
            
            hourButton.leadingAnchor.constraint(equalTo: dayButton.trailingAnchor, constant: 15),
            hourButton.widthAnchor.constraint(equalToConstant: 105),
            hourButton.topAnchor.constraint(equalTo: monthButton.bottomAnchor, constant: 20),
            hourButton.heightAnchor.constraint(equalToConstant: 50),
            
            minButton.leadingAnchor.constraint(equalTo: hourButton.trailingAnchor, constant: 15),
            minButton.widthAnchor.constraint(equalToConstant: 52.5),
            minButton.topAnchor.constraint(equalTo: monthButton.bottomAnchor, constant: 20),
            minButton.heightAnchor.constraint(equalToConstant: 50)
            
        ]
        
        NSLayoutConstraint.activate(constraints)
        colorView.backgroundColor = UIColor(colorLiteralRed: 16.0/255.0, green: 174.0/255.0, blue: 178.0/255.0, alpha: 1)
        colorView.layer.shadowOffset = CGSize(width: 0, height: 5)
    }
    
    
}

