//
//  SongTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-13.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class AlbumSongTableViewCell: UITableViewCell {
    @IBOutlet weak var trackNumberLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var trackIconView: UIView!
    

    private var musicIndicator:ESTMusicIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        musicIndicator = ESTMusicIndicatorView.init(frame: trackIconView.bounds)
        trackIconView.addSubview(musicIndicator)
        musicIndicator.hidesWhenStopped = true
        musicIndicator.state = .stopped
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var isPlaying = false
    
    func setup(title:String?, number:Int) {
        songTitleLabel.text = title
        trackNumberLabel.text = "\(number)"
        
        let theme = ThemeManager.currentTheme
        songTitleLabel.textColor = theme.title.color
        trackNumberLabel.textColor = theme.subtitle.color
        contentView.backgroundColor = theme.background.color
        backgroundColor = theme.background.color
        musicIndicator.tintColor = theme.button.color
        
    }
    
    func setMusicIndicatorState(_ state:ESTMusicIndicatorViewState) {
        musicIndicator.state = state
        trackNumberLabel.isHidden = state != .stopped
    }
}
