//
//  UILabelExtensions.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-06.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    public class func size(withText text: String, forWidth width: CGFloat, withFont font: UIFont) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.font = font
        measurementLabel.text = text
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    public class func size(withText text: String, forHeight height: CGFloat, withFont font: UIFont) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.font = font
        measurementLabel.text = text
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        
        measurementLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
}
