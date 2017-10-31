//
//  AlbumHeaderView.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-13.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol AlbumHeaderProtocol: class {
    func playAlbum()
    func shuffleAlbum()
    func showArtist()
}

class AlbumHeaderView: UIView {
    
    @IBOutlet weak var artworkContainerView:UIView!
    @IBOutlet weak var artworkImageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var artistButton:UIButton!
    @IBOutlet weak var subtitleLabel:UILabel!
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var shuffleButton:UIButton!
    @IBOutlet weak var divider1: UIView!
    @IBOutlet weak var divider2: UIView!
    
    weak var delegate:AlbumHeaderProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        artworkImageView.layer.cornerRadius = 4.0
        artworkImageView.clipsToBounds = true
        
        playButton.layer.cornerRadius = 8.0
        playButton.clipsToBounds = true
        
        shuffleButton.layer.cornerRadius = 8.0
        shuffleButton.clipsToBounds = true
        setTheme()
    }
    
    func setTheme() {
        let theme = ThemeManager.currentTheme
        titleLabel.textColor = theme.title.color
        artistButton.setTitleColor(theme.button.color, for: .normal)
        subtitleLabel.textColor = theme.subtitle.color
        backgroundColor = theme.background.color
        
        shuffleButton.tintColor = theme.button.color
        playButton.tintColor = theme.button.color
        shuffleButton.setTitleColor(theme.button.color, for: .normal)
        playButton.setTitleColor(theme.button.color, for: .normal)
        shuffleButton.backgroundColor = theme.buttonBackground.color
        playButton.backgroundColor = theme.buttonBackground.color
        
        divider1.backgroundColor = theme.detailSecondary.color
        divider2.backgroundColor = theme.detailSecondary.color
        
    }
    
    @IBAction func handlePlayButton(_ sender: Any) {
        delegate?.playAlbum()
    }
    
    @IBAction func handleShuffleButton(_ sender: Any) {
        delegate?.shuffleAlbum()
    }
    
    @IBAction func artistButtonTapped(_ sender: Any) {
        delegate?.showArtist()
    }
    
    
}
