//
//  Util.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/27/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import Contacts
import Firebase
import AVFoundation

class Util {
    
    ///Returns the name of the contact. (Assumes that the given name, family name, and organization names are all available!)
    static func getNameFromContact(_ contact: CNContact) -> String {
        
        if contact.givenName.isEmpty && contact.familyName.isEmpty {
            return contact.organizationName
        } else if contact.givenName.isEmpty {
            return contact.familyName
        } else if contact.familyName.isEmpty {
            return contact.givenName
        } else {
            return "\(contact.givenName) \(contact.familyName)"
        }
    }
    
    ///Adds and saves Login Listener on any view controller. Should be called from viewWillAppear. Will send to Login Page if user is not logged in.
    static func addLoginCheckListener(_ vc: UIViewController) {
        currentLoginCheckListener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                let loginViewController = vc.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                vc.present(loginViewController, animated: true, completion: nil)
            } else {
                
            }
        }
    }
    
    //Formats date on selecting contacts page
    static func formatDateLabelDate(date: Date) -> String {
        let today = Date()
        let dateFormatter = DateFormatter()
        if date.day == today.day {
            dateFormatter.dateFormat = "h:mm a"
            let dateString = dateFormatter.string(from: date)
            return "Today \n \(dateString)"
        } else {
            dateFormatter.dateFormat = "MMMM d, Y \n h:mm a"
            return dateFormatter.string(from: date)
        }
    }
    
    //gets biggest date component of difference between dates
    static func getBiggestComponenet(release: Date) -> String {
        let now = Date()
        let componenets = Calendar.current.dateComponents([.minute,.hour, .day, .month, .year], from: now, to: release)
        if let year = componenets.year, year > 0 {
            return (year == 1) ? "\(year) year" : "\(year) years"
        }
        if let month = componenets.month, month > 0 {
            return (month == 1) ? "\(month) month" : "\(month) months"
        }
        if let day = componenets.day, day > 0 {
            return (day == 1) ? "\(day) day" : "\(day) days"
        }
        if let hour = componenets.hour, hour > 0 {
            return (hour == 1) ? "\(hour) hour" : "\(hour) hours"
        }
        if let minute = componenets.minute, minute > 0 {
            if minute < 1 {
                return "Soon"
            } else {
                return (minute == 1) ? "\(minute) minute" : "\(minute) minutes"
            }
        }
        else {
            return "Now"
        }
    }
    
    //gets thumbnail
    static func getThumbnail(imageData: Data?, videoURL: URL?) -> Data {
        var image: UIImage? = nil
        if let imageData = imageData {
            image = UIImage(data: imageData)
        } else if let videoURL = videoURL {
            let asset = AVAsset(url: videoURL)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            do {
                let cgImage = try imgGenerator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 1), actualTime: nil)
                image = UIImage(cgImage: cgImage)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        let imageSize = CGSize(width: image!.size.width / 6, height: image!.size.height / 6)
        let rect = CGRect(x: 0.0, y: 0.0, width: image!.size.width / 6, height: image!.size.height / 6)
        
        UIGraphicsBeginImageContext(imageSize)
        image!.draw(in: rect)
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let thumbnailData = UIImageJPEGRepresentation(thumbnailImage!, 1.0)
        
        return thumbnailData!
        
    }
    
    //format thumbnail
    static func formatThumbnail(imageData: Data, radius: CGFloat) -> UIImage {
        let image = UIImage(data: imageData)
        let imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = radius
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage!
    }
    
    ///Removes the current Login Listener. Should be called from viewWillDisappear.
    static func removeCurrentLoginCheckListener() {
        currentLoginCheckListener = nil
    }
    
    ///The current Login Listener. If updated, the original listener will be removed.
    static var currentLoginCheckListener: AuthStateDidChangeListenerHandle? {
        willSet {
            if let listener = currentLoginCheckListener {
                Auth.auth().removeStateDidChangeListener(listener)
            }
        }
    }
    
    
}
