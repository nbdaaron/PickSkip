//
//  Media.swift
//  PickSkip
//
//  Created by Eric Duong on 7/20/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation



class Media {
    var mediaID: String!
    var mediaType: String!
    var image: Data?
    var video: URL?
    var date: Date!
    
    init(id: String, type: String, image: Data?, video: URL?, dateInt: Int!) {
        self.mediaID = id
        self.mediaType = type
        self.image = image
        self.video = video
        date = Date(timeIntervalSince1970: TimeInterval(dateInt))
        
    }
    
}
