//
//  PreviewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/30/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class PreviewController: UIViewController {
    
    var video: URL?
    var image: UIImage?
    @IBOutlet weak var previewContent: PreviewView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet weak var hourCounter: CounterButton!
    @IBOutlet weak var minCounter: CounterButton!
    @IBOutlet weak var dayCounter: CounterButton!
    @IBOutlet weak var monthCounter: CounterButton!
    @IBOutlet weak var yearCounter: CounterButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var showCountersButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var downloadCurrentMediaButton: UIButton!
    
    var dateComponents = DateComponents()
    var sendtoDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels(with: sendtoDate)
        
    
        downloadCurrentMediaButton.imageView?.contentMode = .scaleAspectFit
        cancelButton.imageView?.contentMode = .scaleAspectFit
        backButton.imageView?.contentMode = .scaleAspectFit
        forwardButton.imageView?.contentMode = .scaleAspectFit
        forwardButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        forwardButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        forwardButton.layer.shadowOpacity = 0.7
        forwardButton.layer.shadowRadius = 0.0
        forwardButton.layer.masksToBounds = false
        // Shadow and Radius
        showCountersButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        showCountersButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        showCountersButton.layer.shadowOpacity = 0.7
        showCountersButton.layer.shadowRadius = 0.0
        showCountersButton.layer.masksToBounds = false
        
        dateComponents.year = 0
        dateComponents.month = 0
        dateComponents.day = 0
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        buttonsView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        if let video = video  {
            let player = AVPlayer(url: video)
            previewContent.displayVideo(player)
        } else if let image = image {
            previewContent.isHidden = false
            previewContent.displayImage(image)
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
//        buttonsView.isHidden = false
//        optionsView.isHidden = true
        UIView.animate(withDuration: 0.1,
                       animations: {
                        self.showCountersButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        self.forwardButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        },
                       completion: { _ in
                                self.previewContent.pauseVideo()
                                self.buttonsView.isHidden = false
                                self.optionsView.isHidden = true
                        UIView.animate(withDuration: 0.2, animations: {
                            self.forwardButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        })
        })
        
    }

    @IBAction func downloadCurrentMedia(_ sender: Any) {
        if let image = image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else if let videoURL = video {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }, completionHandler: { (saved, error) in
                if let error = error {
                    print("Error downloading video: \(error.localizedDescription)")
                } else {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        } else {
            let alertController = UIAlertController(title: "Error downloading media", message: "Please try again", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    @IBAction func cancelPreview(_ sender: Any) {
        previewContent.removeExistingContent()
        dismiss(animated: false, completion: nil)
    }

    @IBAction func returnToPreview(_ sender: Any) {
        buttonsView.isHidden = true
        optionsView.isHidden = false
        UIView.animate(withDuration: 0.1,
                       animations: {
                        self.showCountersButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        self.previewContent.playVideo()
        
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
        let calendar    = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let components  = calendar.components([.year, .month, .day, .hour, .minute], from: updateDate)
        hourCounter.dateLabel.text = updateDate.hour
        if components.minute! < 10 {
            minCounter.dateLabel.text = "0" + updateDate.minute + " " + updateDate.amPM
        } else {
            minCounter.dateLabel.text = updateDate.minute + " " + updateDate.amPM
        }
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
            if let video = video {
                destination.video = video
            } else if let image = image {
                destination.image = UIImageJPEGRepresentation(image, 1.0)
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


