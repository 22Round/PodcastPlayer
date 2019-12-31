//
//  PodCastsSearchController.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 5/31/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit
import Alamofire

class PodCastsSearchController: UITableViewController, UISearchBarDelegate {
    
    var podcasts = [Podcast]()
    
    let cellId:String = "cellid"
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupSearchBar()
        
        searchBar(searchController.searchBar, textDidChange: "Voong")
        
    }
    
    //MARK:- Setup TableView
    
    fileprivate func setupTableView() {
        
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK:- Setup SearchBar
    
    fileprivate func setupSearchBar() {
        
        self.definesPresentationContext = true
        tableView.tableFooterView = UIView()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    var timer:Timer?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
