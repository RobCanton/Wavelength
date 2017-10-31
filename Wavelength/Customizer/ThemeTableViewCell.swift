//
//  ThemeTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-22.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var colorView1: UIView!
    @IBOutlet weak var colorView2: UIView!
    @IBOutlet weak var colorView3: UIView!
    @IBOutlet weak var colorView4: UIView!
    @IBOutlet weak var colorView5: UIView!
    @IBOutlet weak var colorView6: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cropView(colorView1)
        cropView(colorView2)
        cropView(colorView3)
        cropView(colorView4)
        cropView(colorView5)
        cropView(colorView6)
        
        //containerView.applyShadow(radius: 7.0, opacity: 0.12, height: 0.0, shouldRasterize: false)
    }
    
    let selectedColor = UIColor(red: 0, green: 152/255, blue: 235/255, alpha: 1.0)

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard let theme = cellTheme else { return }
        colorView1.backgroundColor = theme.background.color
        colorView2.backgroundColor = theme.title.color
        colorView3.backgroundColor = theme.subtitle.color
        colorView4.backgroundColor = theme.button.color
        colorView5.backgroundColor = theme.buttonBackground.color
        colorView6.backgroundColor = theme.detailPrimary.color
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        guard let theme = cellTheme else { return }
        colorView1.backgroundColor = theme.background.color
        colorView2.backgroundColor = theme.title.color
        colorView3.backgroundColor = theme.subtitle.color
        colorView4.backgroundColor = theme.button.color
        colorView5.backgroundColor = theme.buttonBackground.color
        colorView6.backgroundColor = theme.detailPrimary.color
    }

    
    var cellTheme:Theme?
    
    func setTheme(_ theme:Theme, canEdit:Bool) {
        self.cellTheme = theme
        titleLabel.text = theme.name
        colorView1.backgroundColor = theme.background.color
        colorView2.backgroundColor = theme.title.color
        colorView3.backgroundColor = theme.subtitle.color
        colorView4.backgroundColor = theme.button.color
        colorView5.backgroundColor = theme.buttonBackground.color
        colorView6.backgroundColor = theme.detailPrimary.color
    }
    
    func cropView(_ view:UIView) {
        view.layer.cornerRadius = view.frame.height / 2
        view.clipsToBounds = true
        
        view.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).cgColor
        view.layer.borderWidth = 0.25
    }
    
}

