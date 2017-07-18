//
//  DataService.swift
//  PickSkip
//
//  Created by Eric Duong on 7/18/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DataService {
    private static let _instance = DataService()
    
    static var instance: DataService {
        return _instance
    }
    
    var mainRef: DatabaseReference {
        return Database.database().reference()
    }
    
    func saveUser(uid: String) {
        let profile: Dictionary<String, AnyObject> = ["firstname": "" as AnyObject, "lastname": "" as AnyObject]
        mainRef.child("users").child(uid).child("profile").setValue(profile)
    }
    
    
}
