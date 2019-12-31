//
//  UserDefaults.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/26/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritedPodCastKey = "favoritedPodCastKey"
    static let downloadedEpisodeKey = "downloadedEpisodeKey"
    
    func downloadeEpisode(episode:Episode) {
        do {
            var downloadedEpisodes = downloadedEpisode()
            downloadedEpisodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(downloadedEpisodes)
            
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
        }catch let episodeErr {
            print("Episode Append Error: ",episodeErr)
        }
    }
    
    func deleteDownloadedEpisode(index:Int) {
        var downloadedEpisodes = downloadedEpisode()
        if !downloadedEpisodes.isEmpty && index < downloadedEpisodes.count {
            
            if let fileUrl = downloadedEpisodes[index].fileUrl {
                guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                guard let fileURL = URL(string: fileUrl) else { return }
                let fileName = fileURL.lastPathComponent
                trueLocation.appendPathComponent(fileName)
                
                do {
                    try FileManager.default.removeItem(at: trueLocation)
                } catch let err {
                    print("Error - could not delete file:", err)
                }
            }
            
            downloadedEpisodes.remove(at: index)
            
            do {
                let data = try JSONEncoder().encode(downloadedEpisodes)
                UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodeKey)
            }catch let episodeErr {
                print("Episode Delete Error: ",episodeErr)
            }
        }
    }
    
    func downloadedEpisode() ->[Episode] {
        
        guard let episodeData = data(forKey: UserDefaults.downloadedEpisodeKey) else { return [] }
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodeData)
            return episodes
        }catch let episodeErr {
            print("Episode Getting Error: ",episodeErr)
        }
        return []
    }
    
    func savedPodcasts() ->[Podcast] {
        
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodCastKey) else {return []}
        do {
            if let podcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Podcast] {
                return podcasts
            }
        } catch {
            print("Couldn't read file.")
        }
        
        return []
    }
}
