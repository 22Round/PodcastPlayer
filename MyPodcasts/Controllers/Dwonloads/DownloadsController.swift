//
//  DownloadsController.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/27/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    let cellId = "cellId"
    var episodes:[Episode]!

    override func viewDidLoad() {
        super.viewDidLoad()

         self.clearsSelectionOnViewWillAppear = false
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        setupTableView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.downloadedEpisode()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    @objc fileprivate func handleDownloadComplete(notification:Notification) {
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else { return }
        
        guard let index = self.episodes.firstIndex(where: {$0.title == episodeDownloadComplete.episodeTitle}) else { return }
        self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
        
    }
    
    @objc fileprivate func handleDownloadProgress(notification:Notification) {
        
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }
        
        
        guard let index = self.episodes.firstIndex(where: {$0.title == title}) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        cell.progressLabel.text = "\(Int(progress * 100))%"
        cell.progressLabel.isHidden = false
        
        if(progress == 1) {
            cell.progressLabel.isHidden = true
        }
        
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }

}
