//
//  EpisodesController+TableView.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/30/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import Foundation
import UIKit

extension EpisodesController {
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Donwload") {  (contextualAction, view, boolValue) in
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadeEpisode(episode: episode)
            
            APIService.shared.downloadEpisode(episode: episode)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        return swipeActions
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        
        let mainTabBarController = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: episode, playListEpisodes: episodes)
        
        /*
         
         let window = UIApplication.shared.keyWindow
         let playersDetailsView = PlayerDetailsView.initFromNib()
         playersDetailsView.frame = self.view.frame
         window?.addSubview(playersDetailsView)
         playersDetailsView.episode = episode
         
         */
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return episodes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
}


extension UIApplication {

    /// The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }

}

