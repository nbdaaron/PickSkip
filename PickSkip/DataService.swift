//
//  DataService.swift
//  PickSkip
//
//  Created by Eric Duong on 7/18/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class DataService {
    private static let _instance = DataService()
    
    static var instance: DataService {
        return _instance
    }
    
    var mainRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var usersRef: DatabaseReference {
        return mainRef.child("users")
    }
    
    var storageRef: StorageReference {
        return Storage.storage().reference(forURL: "gs://pickskip-12241.appspot.com")
    }
    
    var imagesStorageRef: StorageReference {
        return storageRef.child("images")
    }
    
    var videosStorageRef: StorageReference {
        return storageRef.child("videos")
    }
    
    func saveUser() {
        let profile: Dictionary<String, AnyObject> = ["firstname": "" as AnyObject, "lastname": "" as AnyObject]
        
        mainRef.child("users").child(Auth.auth().currentUser!.providerData[0].phoneNumber!).child("profile").setValue(profile)
        
    }
    
    func sendMedia(senderNumber: String, recipients: [String], mediaURL: URL, mediaType: String, releaseDate: Int) {
        let date = Date()
        let pr: Dictionary<String, AnyObject> = ["mediaType": mediaType as AnyObject,
                                                "mediaURL" : mediaURL.absoluteString as AnyObject,
                                                "releaseDate": releaseDate as AnyObject,
                                                "sentDate": Int(date.timeIntervalSince1970) as AnyObject,
                                                "senderNumber": senderNumber as AnyObject,
                                                "recipients": recipients as AnyObject,
                                                "opened": -1 as AnyObject]
        
        let key = mainRef.childByAutoId().key
        
        for recipient in recipients {
            //Add to recipient's history
            usersRef.child(recipient).child("media").child(key).setValue(pr) {
                error, databaseReference in
                if let error = error  {
                    print("error sending message from DataService#sendMedia - History: \(error.localizedDescription)")
                }
            }
            
            //Add to recipient's story with sender.
            mainRef.child("stories").child(recipient).child(senderNumber).child(key).setValue(pr) {
                error, databaseReference in
                if let error = error  {
                    print("error sending message from DataService#sendMedia - Story 1: \(error.localizedDescription)")
                }
            }
            
            if (recipient != senderNumber) {
                //Add to sender's story with recipient (IF recipient != sender to prevent duplicates).
                mainRef.child("stories").child(senderNumber).child(recipient).child(key).setValue(pr) {
                    error, databaseReference in
                    if let error = error  {
                        print("error sending message from DataService#sendMedia - Story 2: \(error.localizedDescription)")
                    }
                }
            }
        }
        

    }
    
    func setOpened(key: String, releaseDate: Int) {
        usersRef.child(Auth.auth().currentUser!.providerData[0].phoneNumber!).child("media").child(key).child("opened").setValue(releaseDate)
    }
    
}
