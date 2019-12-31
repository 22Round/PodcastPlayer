//
//  EpisodeCell.swift
//  MyPodcasts
//
//  Created by Vakhtangi Beridze on 6/7/18.
//  Copyright © 2018 22Round. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pudDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    

    //MARK: - Code Lifecycle
    
    var episode:Episode! {
        didSet {
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            
            let dataFormatter = DateFormatter()
            dataFormatter.dateFormat = "MMM, DD, yyyy"
            
            pudDateLabel.text = dataFormatter.string(from: episode.pudData ?? Date())
            
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImageView.sd_setImage(with: url)
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
