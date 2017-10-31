//
//  ColourPickerView.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-18.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

protocol EditAttributeProtocol: class {
    func colorSaved(_ color:UIColor)
    func valueSaved(_ value:Int)
}

class ColourPickerView:UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var colorWell: ColorWell!
    @IBOutlet weak var colorPicker: ColorPicker!
    @IBOutlet weak var huePicker: HuePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var swatchCollectionView: UICollectionView!
    
    weak var delegate:EditAttributeProtocol?
    
    var pickerController:ColorPickerController!
    
    func setup(withAttribute attribute: ThemeAttributeColor) {
        
        saveButton.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        saveButton.layer.cornerRadius = 4.0
        saveButton.clipsToBounds = true
        saveButton.isEnabled = false
        
        titleLabel.text = attribute.name
        pickerController = ColorPickerController(svPickerView: colorPicker, huePickerView: huePicker, colorWell: colorWell)
        pickerController.color = attribute.color

        
        // get color updates:
        pickerController.onColorChange = { color, finished in
            self.saveButton.backgroundColor = UIColor.white
            self.saveButton.setTitleColor(UIColor.darkGray, for: .normal)
            self.saveButton.isEnabled = true
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        layout.itemSize = CGSize(width: swatchCollectionView.frame.height, height: swatchCollectionView.frame.height)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        swatchCollectionView.setCollectionViewLayout(layout, animated: false)
        let nib = UINib(nibName: "SwatchCollectionViewCell", bundle: nil)
        
        swatchCollectionView.register(nib, forCellWithReuseIdentifier: "swatchCell")
        swatchCollectionView.delegate = self
        swatchCollectionView.dataSource = self
        swatchCollectionView.showsHorizontalScrollIndicator = false
        swatchCollectionView.reloadData()
    }
    
    @IBAction func handleSaveButton(_ sender: Any) {
        guard let color = pickerController.color else { return }
        self.delegate?.colorSaved(color)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ThemeManager.recentColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "swatchCell", for: indexPath) as! SwatchCollectionViewCell
        cell.colorView.backgroundColor = ThemeManager.recentColors[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickerController.color = ThemeManager.recentColors[indexPath.row]
        self.saveButton.backgroundColor = UIColor.white
        self.saveButton.setTitleColor(UIColor.darkGray, for: .normal)
        self.saveButton.isEnabled = true
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}
