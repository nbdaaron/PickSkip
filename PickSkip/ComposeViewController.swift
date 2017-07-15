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
    
    @IBOutlet weak var listOfContactsTable: UITableView!
    

    var centerY : NSLayoutConstraint!
    var tracker: CGFloat = 0.0
    var lowerPanLimit: CGFloat = 0.0
    var upperPanLimit: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setup() {
        centerY = NSLayoutConstraint(item: contactView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.8, constant: 0)
        centerY.isActive = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        contactView.addGestureRecognizer(panGesture)
        
        upperPanLimit = -(self.view.frame.height / 3.3)
        
        listOfContactsTable.isScrollEnabled = false
        
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        var center = sender.view?.center
        let translation = sender.translation(in: sender.view)
        print("Upperpanlimit: \(self.upperPanLimit)")
        
        if (sender.state == UIGestureRecognizerState.changed) {
            
            if (centerY.constant < 0 ){
                centerY.constant += (translation.y - tracker)
            } else {
                centerY.constant += (translation.y - tracker) / 2
            }
            
        }
        print("Y: \(centerY.constant)")
        tracker = translation.y
        
        if (sender.state == UIGestureRecognizerState.ended){
            if (centerY.constant > 0 ){
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
                    self.centerY.constant = 0
                })
            } else if (centerY.constant < self.upperPanLimit){
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
                    self.centerY.constant = self.upperPanLimit
                })
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
