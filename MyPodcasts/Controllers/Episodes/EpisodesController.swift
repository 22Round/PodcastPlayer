//
//  EpisodesController.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/6/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    var podcast:Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl?.toSecureHTTPS() else {return}
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
        }
    }
    
    var episodes = [Episode]()
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         setupNavigationBarButtons()
    }
    
    // MARK: - Setap Work
    
    fileprivate func setupNavigationBarButtons(){
        
        let podcasts = UserDefaults.standard.savedPodcasts()
        let hasFavorited = podcasts.firstIndex(where: {$0.trackName == podcast?.trackName && $0.artistName == podcast?.artistName}) != nil
        if hasFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        }else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite))]
            
            //UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavePodcast))

        }
        
    }
    
    @objc func handleSaveFavorite() {
        
        guard let podcast = self.podcast else { return }
        
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        
        do {
            let setData = try NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)
            UserDefaults.standard.set(setData, forKey: UserDefaults.favoritedPodCastKey)
        } catch {
            print("Couldn't write file")
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
       
        showBadgeHighlight()
    }
    
    fileprivate func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = "New"
    }
    
    @objc func handleFetchSavePodcast () {
        
        let podcasts = UserDefaults.standard.savedPodcasts()
        
        podcasts.forEach({ (podcast) in
            print(podcast.trackName ?? "", podcast.artistName ?? "")
        })
        
    }
    
    fileprivate func setupTableView(){
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
