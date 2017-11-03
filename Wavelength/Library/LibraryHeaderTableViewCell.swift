//
//  LibraryHeaderTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-11-02.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class LibraryHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.backgroundColor = currentTheme.button.color
            self.contentView.backgroundColor = currentTheme.button.color
            self.titleLabel.textColor = currentTheme.background.color
        } else {
            self.backgroundColor = nil
            self.contentView.backgroundColor = nil
            self.titleLabel.textColor = currentTheme.button.color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.backgroundColor = currentTheme.button.color
            self.contentView.backgroundColor = currentTheme.button.color
            self.titleLabel.textColor = currentTheme.background.color
            
        } else {
            self.backgroundColor = nil
            self.contentView.backgroundColor = nil
            self.titleLabel.textColor = currentTheme.button.color
        }
    }
    
}
