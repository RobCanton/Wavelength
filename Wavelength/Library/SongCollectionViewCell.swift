//
//  SongCollectionViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-10.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

protocol SongCollectionViewProtocol:class {
    func playMedia(item: MediaItem)
}

class SongCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var artworkContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var mediaItem:MediaItem!
    var albumItem:AlbumInfo!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        artworkImageView.layer.cornerRadius = 4.0
        artworkImageView.clipsToBounds = true
    }
    
    func setupMediaItem( item: MediaItem) {
        self.mediaItem = item
        self.titleLabel.textColor = ThemeManager.currentTheme.title.color
        self.subtitleLabel.textColor = ThemeManager.currentTheme.subtitle.color
        
        let url = item.artwork.imageURL(size: CGSize(width: artworkImageView.frame.size.width * 3, height: artworkImageView.frame.size.height * 3))
        
        loadImageCheckingCache(withUrl: url.absoluteString, id: item.identifier) { image, fromCache, id in
            if id == self.mediaItem.identifier {
                self.artworkImageView.image = image
            }
        }
        
        titleLabel.text = item.name
        subtitleLabel.text = item.artistName
    }
    
    func setupAlbumItem( item: AlbumInfo) {
        
        self.albumItem = item
        artworkImageView.image = item.artwork?.image(at: artworkImageView.frame.size)
        
        titleLabel.text = item.albumTitle
        subtitleLabel.text = item.albumArtist
    }
    
    func setTheme() {
        // Theme
        let theme = ThemeManager.currentTheme
        self.titleLabel.textColor = theme.title.color
        self.subtitleLabel.textColor = theme.subtitle.color
        self.artworkImageView.backgroundColor = theme.buttonBackground.color
    }

}
