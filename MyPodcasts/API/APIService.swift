//
//  APIService.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/4/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}

class APIService {
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl:String, episodeTitle:String)
    let baseiTunesSearchURL = "https://itunes.apple.com/search"
    static let shared = APIService()
    
    func downloadEpisode(episode:Episode) {
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title":episode.title ?? "", "progress": progress.fractionCompleted])
            
            }.response { (resp) in
                
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(resp.destinationURL?.absoluteString ?? "", episode.title ?? "")
                
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisode()
                guard let index = downloadedEpisodes.firstIndex(where: {$0.title == episode.title && $0.author == episode.author}) else { return }
                downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
                
                do {
                    let data = try JSONEncoder().encode(downloadedEpisodes)
                    UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
                }catch let episodeErr {
                    print("Episode Append Error: ",episodeErr)
                }
        }
    }
    
    
    func fetchEpisodes(feedUrl:String,completionHandler: @escaping ([Episode])->()) {
        
        guard let url = URL(string: feedUrl) else {return}
        
        
        DispatchQueue.global(qos: .background).async {
        
            let parser = FeedParser.init(URL: url)
            parser?.parseAsync(result: { (result) in
                
                if let err = result.error {
                    print("Error parsing XML", err)
                    return
                }
                
                guard let feed = result.rssFeed else {return}
                let episodes = feed.toEpisode()
                completionHandler(episodes)
            })
            
        }
    }
    
    func fetchPodcasts(searchText:String, completionHandler: @escaping ([Podcast])->()) {
        
       
        let parameters = ["term": searchText]
        
        Alamofire.request(baseiTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { (dataResponse) in
            if let error = dataResponse.error {
                print("connection error: ", error)
                return
            }
            
            guard let data = dataResponse.data else {return}
            
            do {
                let searchResult = try JSONDecoder().decode(Searchresults.self, from: data)

                completionHandler(searchResult.results)
             
            }catch let parseErr {
                print("Error on Json Parsing ", parseErr)
            }
        }
    }
    
    struct Searchresults:Decodable {
        let resultCount: Int
        let results:[Podcast]
    }

}
