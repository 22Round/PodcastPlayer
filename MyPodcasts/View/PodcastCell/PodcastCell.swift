//
//  PodcastCell.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/5/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    
    var podcast:Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
            print(podcast.artworkUrl600 ?? "")
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else {
                return
            }
            
            podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
