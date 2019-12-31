//
//  MainTabBarController.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 5/31/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    //MARK:- Vars
    var maximizedTopAnchorConstraint:NSLayoutConstraint!
    var minimizedTopAnchorConstraint:NSLayoutConstraint!
    var bottomAnchorConstraint:NSLayoutConstraint!
    
    //MARK:- Constants
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    

    //MARK:- Code Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UINavigationBar.appearance().prefersLargeTitles = true
        tabBar.tintColor = .purple
        
        setupViewControllers()
        setupPlayerDetailsView()
//        perform(#selector(maximizePlayerDetails), with: nil, afterDelay: 1)
    }
    
    
    //MARK:- Setup Functions
    
    func minimizePlayerDetails(){
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
       
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            
            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 1
        })
    }
    
    
    func maximizePlayerDetails (episode:Episode?, playListEpisodes:[Episode] = []) {
        
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        if episode != nil {
            playerDetailsView.episode = episode
        }
        
        playerDetailsView.playListEpisodes = playListEpisodes
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
        })
        
        self.playerDetailsView.maximizedStackView.alpha = 1
        self.playerDetailsView.miniPlayerView.alpha = 0
    }
    
    
    
    fileprivate func setupPlayerDetailsView() {
        
//        view.addSubview(playerDetailsView)
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant:-65)
        minimizedTopAnchorConstraint.isActive = false
        
        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    
    func setupViewControllers(){
        let layout = UICollectionViewFlowLayout()
        let favoritesController = FavoritesController(collectionViewLayout: layout)
        
        viewControllers = [
            generateNavigationController(for: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(for: PodCastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(for: DownloadsController(), title: "Download", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    
    //MARK:- Helper Functions
    
    fileprivate func generateNavigationController(for rootViewController:UIViewController, title:String, image:UIImage)->UIViewController{
        
        rootViewController.navigationItem.title = title
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        return navController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
