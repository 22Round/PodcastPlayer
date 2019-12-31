//
//  FavoritesController.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/21/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var podcasts:[Podcast]!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupColletionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView?.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = nil
    }
    
    func setupColletionView() {
        
        collectionView?.backgroundColor = .white
        self.collectionView!.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView?.addGestureRecognizer(gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Functions
    
    @objc func handleLongPress (gesture:UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else { return }
        
        let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.podcasts.remove(at: selectedIndexPath.item)
            self.collectionView?.deleteItems(at: [selectedIndexPath])
            
            var listOfPodcasts = UserDefaults.standard.savedPodcasts()
            listOfPodcasts.remove(at: selectedIndexPath.item)
            
            do {
                let setData = try NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)
                //            let setData = NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts)
                UserDefaults.standard.set(setData, forKey: UserDefaults.favoritedPodCastKey)
            } catch {
                print("Couldn't write file")
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel))
        present(alertController, animated: true)
        
    }
}
