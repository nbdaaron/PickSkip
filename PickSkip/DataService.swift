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
    
    func saveUser(uid: String) {
        let profile: Dictionary<String, AnyObject> = ["firstname": "" as AnyObject, "lastname": "" as AnyObject]
        
        mainRef.child("users").child(Auth.auth().currentUser!.phoneNumber!).child("profile").setValue(profile)
        
    }
    
    func sendMedia(senderUID: String, recipients: [String], mediaURL: URL, mediaType: String, releaseDate: Int) {
        let pr: Dictionary<String, AnyObject> = ["mediaType": mediaType as AnyObject,
                                                "mediaURL" : mediaURL.absoluteString as AnyObject,
                                                "releaseDate": releaseDate as AnyObject,
                                                "senderID": senderUID as AnyObject,
                                                "recipients": recipients as AnyObject]
        
        mainRef.child("media").childByAutoId().setValue(pr, withCompletionBlock: {(error, databaseReference) in
            self.mainRef.child("users").child("\(String(describing: Auth.auth().currentUser!.providerData.first!.phoneNumber!))").child("media").child(databaseReference.key).child("releaseDate").setValue(releaseDate)
        })
    }
    
}
