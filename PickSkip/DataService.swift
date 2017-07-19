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
    
    var uid: String = Auth.auth().currentUser!.uid
    
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
    
    func saveUser(uid: String) {
        let profile: Dictionary<String, AnyObject> = ["firstname": "" as AnyObject, "lastname": "" as AnyObject]
        
        mainRef.child("users").child(uid).child("profile").setValue(profile)
        
    }
    
    func sendMedia(senderUID: String, sendingTo: [String], mediaURL: URL) {
        let pr: Dictionary<String, AnyObject> = ["mediaURL" : mediaURL.absoluteString as AnyObject, "senderID": senderUID as AnyObject, "recipients": sendingTo as AnyObject]
        mainRef.child("media").childByAutoId().setValue(pr, withCompletionBlock: {(error, databaseReference) in
            self.mainRef.child("users").child("\(Auth.auth().currentUser!.uid)").child("media").updateChildValues([databaseReference.key: true])
        })
    }
    
}
