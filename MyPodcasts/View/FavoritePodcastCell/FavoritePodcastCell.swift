//
//  FavoritePodcastCell.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/25/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()
    
    var podcast:Podcast! {
        didSet {
            nameLabel.text = podcast.trackName
            nameLabel.text = podcast.artistName
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            
            imageView.sd_setImage(with: url)
        }
    }
    
    
    fileprivate func stylizeUI() {
        nameLabel.text = "podcast name"
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        artistNameLabel.text = "artist name"
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        artistNameLabel.textColor = .lightGray
    }
    
    fileprivate func setupView() {
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        stylizeUI()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
