//
//  Episode.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/7/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import Foundation
import FeedKit


struct Episode: Codable {
    let title:String?
    let pudData:Date?
    let description:String?
   
    let author:String
    let streamUrl:String
    
    var fileUrl:String?
    var imageUrl:String?
    
    init(feedItem:RSSFeedItem) {
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
        self.title = feedItem.title ?? ""
        self.pudData = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ??  feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
    }
}
