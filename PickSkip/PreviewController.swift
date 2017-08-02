//
//  PreviewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/30/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewController: UIViewController {
    
    var player: AVPlayer?
    var image: UIImage?
    @IBOutlet weak var previewContent: PreviewView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet weak var hourCounter: CounterButton!
    @IBOutlet weak var minCounter: CounterButton!
    @IBOutlet weak var dayCounter: CounterButton!
    @IBOutlet weak var monthCounter: CounterButton!
    @IBOutlet weak var yearCounter: CounterButton!
    
    var dateComponents = DateComponents()
    var sendtoDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels(with: sendtoDate)
        
        dateComponents.year = 0
        dateComponents.month = 0
        dateComponents.day = 0
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        buttonsView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        if let player = player  {
            previewContent.displayVideo(player)
        } else if let image = image {
            previewContent.isHidden = false
            previewContent.displayImage(image)
            print(image)
        }
        setupResetGesuture(button: yearCounter.resetButton)
        setupResetGesuture(button: monthCounter.resetButton)
        setupResetGesuture(button: dayCounter.resetButton)
        setupResetGesuture(button: hourCounter.resetButton)
        setupResetGesuture(button: minCounter.resetButton)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func count(_ sender: CounterButton) {
        switch sender.tag {
        case 1:
            dateComponents.hour! += 1
            sender.updateCounter(to: dateComponents.hour!)
        case 2:
            dateComponents.minute! += 5
            sender.updateCounter(to: dateComponents.minute!)
        case 3:
            dateComponents.month! += 1
            sender.updateCounter(to: dateComponents.month!)
        case 4:
            dateComponents.day! += 1
            sender.updateCounter(to: dateComponents.day!)
        case 5:
            dateComponents.year! += 1
            sender.updateCounter(to: dateComponents.year!)
        default:
            print("error counting buttons")
        }
        sendtoDate = Date()
        sendtoDate = Calendar.current.date(byAdding: dateComponents, to: sendtoDate)!
        updateLabels(with: sendtoDate)
    }

    
    
    @IBAction func showButtons(_ sender: Any) {
        buttonsView.isHidden = false
        optionsView.isHidden = true
    }

    
    @IBAction func cancelPreview(_ sender: Any) {
        previewContent.removeExistingContent()
        dismiss(animated: false, completion: nil)
    }

    @IBAction func returnToPreview(_ sender: Any) {
        buttonsView.isHidden = true
        optionsView.isHidden = false
    }
    
    func setupResetGesuture(button: UIButton) {
        let resetGesture = UITapGestureRecognizer(target: self, action: #selector(reset(gesture:)))
        button.addGestureRecognizer(resetGesture)
        
    }
    
    func reset(gesture: UITapGestureRecognizer) {
        guard let button = gesture.view as? UIButton else {return}
        switch button.tag {
        case 1:
            dateComponents.hour! = 0
            hourCounter.updateCounter(to: dateComponents.hour!)
        case 2:
            dateComponents.minute! = 0
            minCounter.updateCounter(to: dateComponents.minute!)
        case 3:
            dateComponents.month! = 0
            monthCounter.updateCounter(to: dateComponents.month!)
        case 4:
            dateComponents.day! = 0
            dayCounter.updateCounter(to: dateComponents.day!)
        case 5:
            dateComponents.year! = 0
            yearCounter.updateCounter(to: dateComponents.year!)
        default:
            print("error counting buttons")
        }
        sendtoDate = Date()
        sendtoDate = Calendar.current.date(byAdding: dateComponents, to: sendtoDate)!
        updateLabels(with: sendtoDate)
    }
    
    func updateLabels(with updateDate: Date) {
        hourCounter.dateLabel.text = updateDate.hour
        minCounter.dateLabel.text = updateDate.minute + " " + updateDate.amPM
        monthCounter.dateLabel.text = updateDate.month
        yearCounter.dateLabel.text = updateDate.year
        dayCounter.dateLabel.text = updateDate.day
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContactsView" {
            let navController = segue.destination as! UINavigationController
            let destination = navController.topViewController as! ContactsViewController
            destination.releaseDate = sendtoDate
            destination.dateComponenets = dateComponents
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

extension Formatter {
    static let month: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    static let hour12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter
    }()
    static let minute: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "m"
        return formatter
    }()
    static let amPM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }()
    static let year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "Y"
        return formatter
    }()
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    
}


