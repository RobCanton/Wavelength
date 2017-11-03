//
//  ArtistTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-11-03.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class ArtistTableViewCell: UITableViewCell {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(withArtist artist:Artist) {
        artworkImageView.layer.cornerRadius = 4.0
        artworkImageView.clipsToBounds = true
        artworkImageView.image = artist.artwork?.image(at: artworkImageView.frame.size)
        nameLabel.text = artist.name
        nameLabel.textColor = currentTheme.title.color
        backgroundColor = currentTheme.background.color
        contentView.backgroundColor = currentTheme.background.color
    }
    
}
