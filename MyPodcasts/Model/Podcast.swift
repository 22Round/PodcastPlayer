//
//  File.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 5/31/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import Foundation

class Podcast:NSObject, Decodable, NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackName ?? "", forKey: "trackNameKay")
        aCoder.encode(artistName ?? "", forKey: "artistNameKay")
        aCoder.encode(artworkUrl600 ?? "", forKey: "artworkKay")
        aCoder.encode(feedUrl ?? "", forKey: "feedkey")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKay") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKay") as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkKay") as? String
        self.feedUrl = aDecoder.decodeObject(forKey: "feedkey") as? String
    }
    
    var trackName:String?
    var artistName:String?
    var artworkUrl600:String?
    var trackCount:Int?
    var feedUrl:String?
    
}
