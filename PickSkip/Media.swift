//
//  Media.swift
//  PickSkip
//
//  Created by Eric Duong on 7/20/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import Firebase


class Media {
    var senderNumber: String!
    var mediaType: String!
    var image: Data?
    var video: URL?
    var releaseDate: Date!
    var sentDate: Date!
    var url: StorageReference!
    var loadState: LoadState = .unloaded
    var key: String!
    var state: Bool!
    
    init(senderNumber: String, key: String, type: String, releaseDateInt: Int!, sentDateInt: Int!, url: StorageReference!, state: Bool!) {
        self.senderNumber = senderNumber
        self.mediaType = type
        self.url = url
        self.key = key
        self.state = state
        releaseDate = Date(timeIntervalSince1970: TimeInterval(releaseDateInt))
        sentDate = Date(timeIntervalSince1970: TimeInterval(sentDateInt))
        
    }
    
    func load(completion: @escaping () -> Void) {
        self.loadState = .loading
        url.getData(maxSize: Constants.maxDownloadSize, completion: {(data, error) in
            if let error = error {
                print("Error loading image from Media#load: \(error.localizedDescription)")
            } else if self.mediaType == "image" {
                
                self.image = data
                self.loadState = .loaded
                completion()
                
            } else if self.mediaType == "video" {
                
                //implement video handling
                //self.video = data
                self.loadState = .loaded
                completion()
                
            } else {
                print("Error: Invalid type from Media#load!")
            }
        })
    }
    
}

enum LoadState {
    case unloaded
    case loading
    case loaded
}
