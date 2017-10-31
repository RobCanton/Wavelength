//
//  ThemesViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-22.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class ThemesViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView:UITableView!
    
    var closeButton:UIBarButtonItem!
    var setThemeButton: UIBarButtonItem!
    var selectedIndexPath:IndexPath?
    
    var bottomBarHeight:CGFloat = 44.0
    
    var newThemeButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Themes"
        view.backgroundColor = UIColor.white
        
        closeButton = UIBarButtonItem(image: UIImage(named:"delete"), style: .plain, target: self, action: #selector(close))//UIBarButtonItem(title: "delete", style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = closeButton
        setThemeButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTheme))
        navigationItem.rightBarButtonItem = setThemeButton
        
//        newThemeButton = UIButton(frame: CGRect(x: 0, y: view.bounds.height - bottomBarHeight, width: view.bounds.width, height: bottomBarHeight))
//        newThemeButton.setTitle("+ New Theme", for: .normal)
//        newThemeButton.setTitleColor(UIColor(red: 0, green: 152/255, blue: 235/255, alpha: 1.0), for: .normal)
//        newThemeButton.addTarget(self, action: #selector(newTheme), for: .touchUpInside)
//        view.addSubview(newThemeButton)
        
        tableView = UITableView(frame: CGRect(x:0, y:0, width:view.bounds.width, height: view.bounds.height), style: .plain)
        let nib = UINib(nibName: "ThemeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "themeCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ThemeManager.fetchCustomThemes()
        tableView.reloadData()
        
        for i in 0..<ThemeManager.defaultThemes.count {
            let theme = ThemeManager.defaultThemes[i]
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0))
            if theme.name == ThemeManager.currentTheme.name {
                cell?.accessoryType = .checkmark
                break
            } else {
                cell?.accessoryType = .none
            }
        }
        
        for i in 0..<ThemeManager.customThemes.count {
            let theme = ThemeManager.customThemes[i]
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1))
            if theme.name == ThemeManager.currentTheme.name {
                cell?.accessoryType = .checkmark
                break
            } else {
                cell?.accessoryType = .none
            }
        }
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ThemeManager.defaultThemes.count
        case 1:
            return ThemeManager.customThemes.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath) as! ThemeTableViewCell
        switch indexPath.section {
        case 0:
            cell.setTheme(ThemeManager.defaultThemes[indexPath.row], canEdit: false)
            break
        case 1:
            cell.setTheme(ThemeManager.customThemes[indexPath.row], canEdit: true)
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return ThemeManager.customThemes.count > 0 ? "Custom Themes" : nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var _theme:Theme?
        switch indexPath.section {
        case 0:
            _theme = ThemeManager.defaultThemes[indexPath.row]
        case 1:
            _theme = ThemeManager.customThemes[indexPath.row]
        default:
            break
        }
        guard let theme = _theme else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Use", style: .default, handler: { _ in
            ThemeManager.setNewTheme(theme)
            self.dismiss(animated: true, completion: nil)
        }))
        if indexPath.section == 1 {
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
                let controller = CustomizerViewController()
                controller._tempTheme = theme
                self.navigationController?.pushViewController(controller, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                ThemeManager.deleteTheme(theme)
                ThemeManager.fetchCustomThemes()
                self.tableView.reloadData()
            }))
        }
        
       
        self.present(alert, animated: true, completion: nil)

    }
    
    @objc func setTheme() {
        print("Set Theme")
        guard let index = selectedIndexPath else { return }
        switch index.section {
        case 0:
            ThemeManager.setNewTheme(ThemeManager.defaultThemes[index.row])
            break
        case 1:
            ThemeManager.setNewTheme(ThemeManager.customThemes[index.row])
            break
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func newTheme() {
        let controller = CustomizerViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
