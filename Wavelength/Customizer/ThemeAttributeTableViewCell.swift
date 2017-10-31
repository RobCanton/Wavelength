//
//  ThemeAttributeTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-18.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class ThemeAttributeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var gapView: UIView!
    @IBOutlet weak var switchView: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorView.layer.cornerRadius = colorView.frame.width / 2
        colorView.clipsToBounds = true
        
        colorView.applyShadow(radius: 5.0, opacity: 0.2, height: 0.0, shouldRasterize: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        
        let color2 = gapView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if(selected) {
            colorView.backgroundColor = color
            gapView.backgroundColor = color2
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        
        let color2 = gapView.backgroundColor
        super.setSelected(highlighted, animated: animated)
        
        if(highlighted) {
            colorView.backgroundColor = color
            gapView.backgroundColor = color2
        }
    }
    weak var themeAttribute: ThemeAttribute?
    func set(attribute: ThemeAttribute) {
        themeAttribute = attribute
        titleLabel.text = attribute.name
        switch attribute {
        case is ThemeAttributeColor:
            let colorAttribute = attribute as! ThemeAttributeColor
            colorView.backgroundColor = colorAttribute.color
            colorView.isHidden = false
            valueLabel.isHidden = true
            switchView.isHidden = true
            selectionStyle = .default
            break
        case is ThemeAttributeValue:
            let floatAttribute = attribute as! ThemeAttributeValue
            valueLabel.text = "\(floatAttribute.value)%"
            colorView.backgroundColor = nil
            colorView.isHidden = true
            valueLabel.isHidden = false
            switchView.isHidden = true
            selectionStyle = .default
            break
        case is ThemeAttributeBool:
            let boolAttribute = attribute as! ThemeAttributeBool
            switchView.isHidden = false
            print("\(boolAttribute.name): \(boolAttribute.value)")
            switchView.setOn(boolAttribute.value, animated: false)
            valueLabel.text = boolAttribute.value ? "ON" : "OFF"
            colorView.isHidden = true
            valueLabel.isHidden = false
            selectionStyle = .none
            break
        default:
            colorView.backgroundColor = nil
            colorView.isHidden = true
            valueLabel.isHidden = true
            switchView.isHidden = true
            break

        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        guard let attribute = themeAttribute as? ThemeAttributeBool else { return }
        valueLabel.text = sender.isOn ? "ON" : "OFF"
        attribute.value = sender.isOn
    }
    
    
    
}
