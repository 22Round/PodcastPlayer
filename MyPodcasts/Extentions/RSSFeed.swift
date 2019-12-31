//
//  RSSFeed.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/8/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import FeedKit

extension RSSFeed {
    func toEpisode() -> [Episode] {
        
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]()
        
        items?.forEach({ (feedItem) in
            
            var episode = Episode(feedItem: feedItem)
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            
            episodes.append(episode)
        })
        
        return episodes
    }
}


