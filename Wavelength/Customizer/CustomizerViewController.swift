//
//  CustomizerViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-18.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

class CustomizerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "attributeCell"
    var tableView:UITableView!
    
    let messageWrapper = SwiftMessages()
    
    var editingTheme:Theme!
    
    var cancelButton:UIBarButtonItem!
    var saveThemeButton:UIBarButtonItem!
    
    var themeChanged = false
    
    var nameHeader:ThemeNameView!
    
    var _tempTheme:Theme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        let nib = UINib(nibName: "ThemeAttributeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        
        nameHeader = UINib(nibName: "ThemeNameView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ThemeNameView
        nameHeader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width,height: 64.0)
        nameHeader.textField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        nameHeader.textField.delegate = self
        
        tableView.tableHeaderView = nameHeader
        tableView.tableFooterView = UIView(frame:CGRect(x:0,y:0,width:tableView.frame.width,height: 120.0))
        view.addSubview(tableView)
        tableView.keyboardDismissMode = .interactive
        
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        saveThemeButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTheme))
        
        navigationItem.rightBarButtonItem = saveThemeButton
        
        if let tempTheme = _tempTheme {
            title = "Edit Theme"
            editingTheme = tempTheme.copy
            nameHeader.textField.text = editingTheme.name
            saveThemeButton.isEnabled = true
        } else {
            title = "New Theme"
            editingTheme = ThemeManager.currentTheme.copy
            saveThemeButton.isEnabled = false
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return editingTheme.attributes.count
        case 1:
            return editingTheme.musicBarAttributes.count
        case 2:
            return editingTheme.miscAttributes.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General"
        case 1:
            return "Music Bar"
        case 2:
            return "Misc"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ThemeAttributeTableViewCell
        switch indexPath.section {
        case 0:
            cell.set(attribute: editingTheme.attributes[indexPath.row])
            break
        case 1:
            cell.set(attribute: editingTheme.musicBarAttributes[indexPath.row])
            break
        case 2:
            cell.set(attribute: editingTheme.miscAttributes[indexPath.row])
            break
        default:
            break
        }
        
        return cell
    }
    
    var selectedIndexPath:IndexPath?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var _attribute:ThemeAttribute? = nil
        switch indexPath.section {
        case 0:
            _attribute = editingTheme.attributes[indexPath.row]
            break
        case 1:
            _attribute = editingTheme.musicBarAttributes[indexPath.row]
            break
        case 2:
            _attribute = editingTheme.miscAttributes[indexPath.row]
        default:
            break
        }
        
        guard let attribute = _attribute else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if let colorAttribute = attribute as? ThemeAttributeColor {
            self.selectedIndexPath = indexPath
            let sortOptionsView = UINib(nibName: "ColourPickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ColourPickerView
            let messageView = BaseView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.5))
            messageView.installContentView(sortOptionsView)
            messageView.preferredHeight = view.frame.height * 0.5
            messageView.configureDropShadow()
            sortOptionsView.setup(withAttribute: colorAttribute)
            sortOptionsView.delegate = self
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            config.duration = .forever
            config.presentationStyle = .bottom
            config.dimMode = .gray(interactive: true)
            config.interactiveHide = false
            // Specify one or more event listeners to respond to show and hide events.
            config.eventListeners.append() { event in
                if case .didHide = event {
                    if let selectedIndex = self.selectedIndexPath {
                        self.tableView.deselectRow(at: selectedIndex, animated: true)
                    }
                }
                
            }
            messageWrapper.show(config: config, view: messageView)
        } else if let valueAttribute = attribute as? ThemeAttributeValue {
            self.selectedIndexPath = indexPath
            let sortOptionsView = UINib(nibName: "ValuePickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ValuePickerView
            let messageView = BaseView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.25))
            messageView.installContentView(sortOptionsView)
            messageView.preferredHeight = view.frame.height * 0.25
            messageView.configureDropShadow()
            sortOptionsView.setup(withAttribute: valueAttribute)
            sortOptionsView.delegate = self
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            config.duration = .forever
            config.presentationStyle = .bottom
            config.dimMode = .gray(interactive: true)
            config.interactiveHide = false
            // Specify one or more event listeners to respond to show and hide events.
            config.eventListeners.append() { event in
                if case .didHide = event {
                    if let selectedIndex = self.selectedIndexPath {
                        self.tableView.deselectRow(at: selectedIndex, animated: true)
                    }
                }
                
            }
            messageWrapper.show(config: config, view: messageView)
        }
        
    }
    
    @objc func saveTheme() {
        print("SaveTheme")
        if editingTheme.name == "" { return }
        if _tempTheme != nil {
            ThemeManager.updateTheme(editingTheme)
            self.navigationController?.popViewController(animated: true)
        } else {
            let addedThemeSuccessfully = ThemeManager.addNewTheme(editingTheme)
            if !addedThemeSuccessfully {
                let alert = UIAlertController(title: "Theme name already exists", message: "Try another name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @objc func handleCancel() {
        print("cancel")
        if themeChanged {
            let alert = UIAlertController(title: "Discard changes?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension CustomizerViewController: EditAttributeProtocol {
    func colorSaved(_ color: UIColor) {
        themeChanged = true
        print("Color Saved")
        messageWrapper.hideAll()
        
        guard let selectedIndex = selectedIndexPath else { return }
        tableView.deselectRow(at: selectedIndex, animated: true)
        
        var attribute:ThemeAttribute? = nil
        switch selectedIndex.section {
        case 0:
            attribute = editingTheme.attributes[selectedIndex.row]
            break
        case 1:
            attribute = editingTheme.musicBarAttributes[selectedIndex.row]
            break
        case 2:
            attribute = editingTheme.miscAttributes[selectedIndex.row]
            break
        default:
            break
        }
        
        if let colorAttribute = attribute as? ThemeAttributeColor {
            colorAttribute.color = color
        }
        
        ThemeManager.addRecentColor(color)
        tableView.reloadRows(at: [selectedIndex], with: .automatic)
    }
    
    func valueSaved(_ value: Int) {
        messageWrapper.hideAll()
        themeChanged = true
        guard let selectedIndex = selectedIndexPath else { return }
        tableView.deselectRow(at: selectedIndex, animated: true)
        
        var attribute:ThemeAttribute? = nil
        switch selectedIndex.section {
        case 0:
            attribute = editingTheme.attributes[selectedIndex.row]
            break
        case 1:
            attribute = editingTheme.musicBarAttributes[selectedIndex.row]
            break
        case 2:
            attribute = editingTheme.miscAttributes[selectedIndex.row]
            break
        default:
            break
        }
        
        if let valueAttribute = attribute as? ThemeAttributeValue {
            valueAttribute.value = value
        }
        
        tableView.reloadRows(at: [selectedIndex], with: .automatic)
    }
    
    @objc func nameChanged(_ target:UITextField) {
        themeChanged = true
        saveThemeButton.isEnabled = target.text != nil && target.text != ""
        editingTheme.name = target.text != nil ? target.text! : ""
    }
    
}

extension CustomizerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


