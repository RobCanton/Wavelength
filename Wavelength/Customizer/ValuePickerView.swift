//
//  ValuePickerView.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-20.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class ValuePickerView:UIView {
    
    @IBOutlet weak var valueView:UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var sliderView:UISlider!
    @IBOutlet weak var saveButton:UIButton!
    
    weak var delegate:EditAttributeProtocol?
    
    func setup(withAttribute attribute: ThemeAttributeValue) {
        saveButton.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        saveButton.layer.cornerRadius = 4.0
        saveButton.clipsToBounds = true
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        saveButton.isEnabled = false
        valueView.layer.cornerRadius = valueView.frame.height / 2
        valueView.clipsToBounds = true
        
        titleLabel.text = attribute.name
        valueLabel.text = "\(attribute.value)%"
        
        sliderView.setValue(Float(attribute.percentageValue), animated: false)
        sliderView.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        
    }
    
    @objc func sliderChanged() {
        let intValue = Int(sliderView.value * 100.0)
        valueLabel.text = "\(intValue)%"
        saveButton.backgroundColor = UIColor.white
        saveButton.setTitleColor(UIColor.darkGray, for: .normal)
        saveButton.isEnabled = true
    }
    
    @objc func handleSave() {
        delegate?.valueSaved(Int(sliderView.value * 100.0))
    }
}
