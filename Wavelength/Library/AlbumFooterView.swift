//
//  AlbumFooterView.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-23.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class AlbumFooterView:UIView {
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var divider: UIView!
    
    func setTheme() {
        let theme = ThemeManager.currentTheme
        divider.backgroundColor = theme.detailSecondary.color
        label.textColor = theme.subtitle.color
    }
}
