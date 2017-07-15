//
//  ComposeViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/14/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var listOfContactsTable: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    
    @IBOutlet weak var yearButton: CounterButton!

    @IBOutlet weak var monthButton: CounterButton!
    
    @IBOutlet weak var weekButton: CounterButton!
    @IBOutlet weak var dayButton: CounterButton!
    @IBOutlet weak var hourButton: CounterButton!
    @IBOutlet weak var minButton: CounterButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var contactViewTop: NSLayoutConstraint!
    var tracker: CGFloat = 0.0
    var lowerPanLimit: CGFloat = 0.0
    var upperPanLimit: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupButtons()
        self.view.bringSubview(toFront: contactView)
        contactView.layer.cornerRadius = contactView.frame.width / 50
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    func setupButtons(){
        yearButton.type = "year"
        monthButton.type = "month"
        weekButton.type = "week"
        dayButton.type = "day"
        hourButton.type = "hour"
        minButton.type = "min"
        yearButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        
        monthButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        weekButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        dayButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        hourButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        minButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("frambefore: \(contactView.frame.minY)")
        upperPanLimit = -(contactView.frame.minY - headerView.frame.height)
        print("upperpanlimi: \(upperPanLimit)")
    }
    
    
    func setup() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        contactView.addGestureRecognizer(panGesture)
        
        
        print(contactViewTop.constant)
        
        listOfContactsTable.isScrollEnabled = false
        
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        if (sender.state == UIGestureRecognizerState.changed) {
            
            if (contactViewTop.constant > 0 ){
                contactViewTop.constant += (translation.y - tracker) / 2
            } else {
                contactViewTop.constant += (translation.y - tracker)
            }
            
        }
        print("Y: \(contactViewTop.constant)")
        tracker = translation.y
        
        if (sender.state == UIGestureRecognizerState.ended){
            if (contactViewTop.constant > 0 ){
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
                    self.contactViewTop.constant = 0
                    self.view.layoutIfNeeded()
                })
            } else if (contactView.frame.minY < self.headerView.frame.maxY){
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
                    self.contactViewTop.constant = self.upperPanLimit
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func didPress(sender: CounterButton) {
        sender.count += 1
        if sender.type == "min" {
            sender.setTitle(String(sender.count) + "\n" + sender.type, for: .normal)
        }else {
            sender.setTitle(String(sender.count) + " " + sender.type, for: .normal)
        }
        
//        switch sender.type {
//        case "year":
//            dateComponents.year = sender.count
//        case "month":
//            dateComponents.month = sender.count
//        case "week":
//            dateComponents.day = sender.count * 7
//        case "day":
//            dateComponents.day = sender.count
//        case "hour":
//            dateComponents.hour = sender.count
//        case "min":
//            dateComponents.minute = sender.count
//        default:
//            print("timebutton didn't fire")
//        }
//        
//        let futureDate = Calendar.current.date(byAdding: dateComponents, to: date)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = DateFormatter.Style.long
//        nowDate = dateFormatter.string(from: futureDate!)
//        dateMonthYearLabel.text = nowDate
//        
//        let timeformatter = DateFormatter()
//        timeformatter.timeStyle = DateFormatter.Style.short
//        nowTime = timeformatter.string(from: futureDate!)
//        timeLabel.text = nowTime
        
    }

}
