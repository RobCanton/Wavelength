//
//  MusicPlayerBar.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-04.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer

protocol MusicPlayerBarProtocol:class {
    func playMedia()
    func skipMedia()
}

class MusicPlayerBar: UIView {

    @IBOutlet weak var mediaImageContainerView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaTitleView: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    var blurView:VisualEffectView!
    weak var delegate:MusicPlayerBarProtocol?
    
    func setupViews() {
        mediaImageContainerView.applyShadow(radius: 6.0, opacity: 0.4, height: 2.0, shouldRasterize: false)
        mediaImageView.layer.cornerRadius = 4.0
        mediaImageView.clipsToBounds = true
        
        blurView?.removeFromSuperview()
        blurView = VisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurView.frame = self.bounds
        blurView.colorTint = .white
        blurView.colorTintAlpha = 0.0
        blurView.scale = 1
        blurView.blurRadius = 1.0
        self.insertSubview(blurView, at: 0)
        
        setTheme() 
    }
    
    func setupMediaItem( item: MPMediaItem) {
        
        mediaImageView.image = item.artwork?.image(at: mediaImageView.frame.size)
        mediaTitleView.text = item.title
    }
    
    @IBAction func handlePlayButton(_ sender: Any) {
        delegate?.playMedia()
    }
    
    @IBAction func handleSkipButton(_ sender: Any) {
        delegate?.skipMedia()
    }
    
    func setTheme() {
        let theme = ThemeManager.currentTheme
        blurView?.colorTint = theme.musicBarBackground.color
        blurView?.colorTintAlpha = theme.musicBarColorAlpha.percentageValue
        blurView?.blurRadius = theme.musicBarBlurIntensity.percentageValue * 100.0
        mediaTitleView.textColor = theme.title.color
        playButton.tintColor = theme.musicBarButton.color
        skipButton.tintColor = theme.musicBarButton.color
        
    }
}
