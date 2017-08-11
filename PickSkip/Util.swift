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
    
    static func formateDateLabelDate(date: Date) -> String {
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
