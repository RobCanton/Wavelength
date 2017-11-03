//
//  SongTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-11-03.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        artworkImageView.layer.cornerRadius = 4.0
        artworkImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(withSong song:Song) {
        artworkImageView.image = song.artwork?.image(at: artworkImageView.frame.size)
        artworkImageView.backgroundColor = currentTheme.detailSecondary.color
        artworkImageView.layer.borderColor = currentTheme.detailSecondary.color.cgColor
        
        titleLabel.text = song.name
        subtitleLabel.text = song.artistName
    }
    
}
