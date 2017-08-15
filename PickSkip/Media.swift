//
//  Media.swift
//  PickSkip
//
//  Created by Eric Duong on 7/20/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

class Media {
    var senderNumber: String!
    var mediaType: String!
    var image: Data?
    var thumbnailData: Data?
    var video: AVPlayer?
    var releaseDate: Date!
    var sentDate: Date!
    var url: StorageReference!
    var thumbnailRef: StorageReference!
    var loadState: LoadState = .unloaded
    var key: String!
    var openDate: Int!
    
    init(senderNumber: String, key: String, type: String, releaseDateInt: Int!, sentDateInt: Int!, url: StorageReference!, openDate: Int) {
        self.senderNumber = senderNumber
        self.mediaType = type
        self.url = url
        self.key = key
        releaseDate = Date(timeIntervalSince1970: TimeInterval(releaseDateInt))
        sentDate = Date(timeIntervalSince1970: TimeInterval(sentDateInt))
        self.openDate = openDate
    }
    
    init(senderNumber: String, key: String, type: String, releaseDateInt: Int!, sentDateInt: Int!, url: StorageReference!, openDate: Int, thumbnailReference: StorageReference!) {
        self.senderNumber = senderNumber
        self.mediaType = type
        self.url = url
        self.key = key
        self.thumbnailRef = thumbnailReference
        releaseDate = Date(timeIntervalSince1970: TimeInterval(releaseDateInt))
        sentDate = Date(timeIntervalSince1970: TimeInterval(sentDateInt))
        self.openDate = openDate
        
    }
    
//    func loadThumbnail(completion: @escaping () -> Void) {
//        thumbnailRef.getData(maxSize: Constants.maxDownloadSize, completion: {(data, error) in
//            if let error = error{
//                print(error.localizedDescription)
//            } else {
//                if let data = data {
//                    self.thumbnailData = data
//                    completion()
//                }
//            }
//        })
//    }
    
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
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filePath = documentsURL.appendingPathComponent(Constants.videoFileName)
                try! data?.write(to: filePath, options: Data.WritingOptions.atomic)
                self.video = AVPlayer(url: filePath)
                
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
