//
//  Contact.swift
//  PickSkip
//
//  Created by Eric Duong on 8/24/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import Foundation

class Contact: Equatable {
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    
    init(first: String, last: String, number: String) {
        self.firstName = first
        self.lastName = last
        self.phoneNumber = number
    }
    
    public static func ==(lhs: Contact, rhs: Contact) -> Bool{
        return
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.phoneNumber == rhs.phoneNumber
    }
    
}
