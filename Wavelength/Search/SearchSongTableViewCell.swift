//
//  SearchSongTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-24.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

import MediaPlayer

class SearchSongTableViewCell: UITableViewCell {

    @IBOutlet weak var artworkImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    
    var mediaItem:MediaItem?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        artworkImageView.layer.cornerRadius = 4.0
        artworkImageView.clipsToBounds = true
        
        artworkImageView.layer.borderWidth = 0.25
        artworkImageView.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItem(_ item:MPMediaItem) {
        artworkImageView.image = item.artwork?.image(at: artworkImageView.frame.size)
        artworkImageView.backgroundColor = currentTheme.detailSecondary.color
        artworkImageView.layer.borderColor = currentTheme.detailSecondary.color.cgColor
        
        titleLabel.text = item.title
        artistLabel.text = item.artist
        albumLabel.text = item.albumTitle
    }
    
    func setItem(_ item:MediaItem) {
        titleLabel.text = item.name
        artistLabel.text = item.artistName
        
    }
    
}
