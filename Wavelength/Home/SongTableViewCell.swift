//
//  SongTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-10.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
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
    
}
