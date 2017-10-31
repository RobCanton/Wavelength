//
//  QueueTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-14.
//  Copyright © 2017 Robert Canton. All rights reserved.
//  with help from Renee Ly

import UIKit
import MediaPlayer

class QueueTableViewCell: UITableViewCell {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        artworkImageView.layer.cornerRadius = 4.0
        artworkImageView.clipsToBounds = true
        
        artworkImageView.layer.borderWidth = 0.25
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItem(_ item:MPMediaItem) {
        artworkImageView.image = item.artwork?.image(at: artworkImageView.frame.size)
        titleLabel.text = item.title
        subtitleLabel.text = item.artist
        let theme = ThemeManager.currentTheme
        self.backgroundColor = theme.background.color
        self.contentView.backgroundColor = theme.background.color
        titleLabel.textColor = theme.title.color
        subtitleLabel.textColor = theme.subtitle.color
        artworkImageView.backgroundColor = theme.detailSecondary.color
        artworkImageView.layer.borderColor = theme.detailSecondary.color.cgColor
    }
    
}
