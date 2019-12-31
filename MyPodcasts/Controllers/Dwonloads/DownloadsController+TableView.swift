//
//  DownloadsController+TableView.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/30/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import Foundation
import UIKit

extension DownloadsController {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playListEpisodes: self.episodes)
        }else {
            let alertController = UIAlertController(title: "File URL not found", message: "cannot play local file, play stream url instead", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playListEpisodes: self.episodes)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }
    }
    
     override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            UserDefaults.standard.deleteDownloadedEpisode(index: indexPath.row)
            self.episodes = UserDefaults.standard.downloadedEpisode()
            let indexPath = IndexPath(item: indexPath.row, section: 0)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        return swipeActions
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
}
