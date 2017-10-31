//
//  MusicPlayerButton.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-19.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class MusicPlayerButton: UIButton {
    
    var highlightedColor = ThemeManager.currentTheme.buttonBackground.color
    {
        didSet {
            if isHighlighted {
                backgroundColor = highlightedColor
            }
        }
    }
    var defaultColor = UIColor.clear
    {
        didSet {
            if !isHighlighted {
                backgroundColor = defaultColor
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = highlightedColor
                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
                    self.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                    self.backgroundColor = self.highlightedColor
                }, completion: { _ in
                })
            } else {
                backgroundColor = defaultColor
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
    func animateTap() {
        self.backgroundColor = self.highlightedColor
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
            self.backgroundColor = self.defaultColor
        }, completion: { _ in
            
        })
    }
    
}
