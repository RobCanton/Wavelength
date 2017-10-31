//
//  ChatCollectionViewHeader.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-05.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import MediaPlayer

class ChatCollectionViewHeader: UICollectionReusableView {

    @IBOutlet weak var mediaImageContainerView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaTitleView: UILabel!
    @IBOutlet weak var mediaSubtitleView: UILabel!
    @IBOutlet weak var skipBackButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    
    func setupViews() {
        mediaImageContainerView.applyShadow(radius: 6.0, opacity: 0.12, height: 2.0, shouldRasterize: false)
        mediaImageView.layer.cornerRadius = 4.0
        mediaImageView.clipsToBounds = true
        
    }
    
    func setupMediaItem( item: MPMediaItem) {
        
        mediaImageView.image = item.artwork?.image(at: mediaImageView.frame.size)
        mediaTitleView.text = item.title
    }
    
}
