//
//  ArtistsViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-11-02.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class ArtistsViewController:UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewIndexDataSource, TableViewIndexDelegate  {
    
    var authorizationManager: AuthorizationManager!
    var appleMusicManager: AppleMusicManager!
    var musicPlayerManager: MusicPlayerManager!
    var mediaLibraryManager: MediaLibraryManager!
    
    var artists = [Artist]()
    var tableView:UITableView!
    
    var indexSectionTitles = [String]()
    var indexView: TableViewIndex!
    var artistsSections = [String:[Artist]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        title = "Artists"
        tableView = UITableView(frame: view.bounds, style: .plain)
        let nib = UINib(nibName: "ArtistTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "artistCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView(frame: CGRect(x:0,y:0,width:tableView.bounds.width, height: 120.0))
        view.addSubview(tableView)
        artists = mediaLibraryManager.artistsSorted
        
        for artist in artists {
            if let firstChar = artist.nameExcludingCommonPrefixes.characters.first {
                var letter = "\(firstChar)".uppercased()
                if Int(letter) != nil {
                    letter = "#"
                }
                
                if artistsSections[letter] != nil {
                    artistsSections[letter]!.append(artist)
                } else {
                    artistsSections[letter] = [artist]
                }
            }
        }
        
        for (key, array) in artistsSections {
            artistsSections[key]?.sort(by: { $0.nameExcludingCommonPrefixes.localizedCaseInsensitiveCompare($1.nameExcludingCommonPrefixes) == .orderedAscending })
            
            print(key)
            print(array)
            
            if !indexSectionTitles.contains(key) {
                indexSectionTitles.append(key)
            }
        }
        indexSectionTitles.sort(by: {
            $0 < $1
        })
        
        if let first = indexSectionTitles.first {
            if first == "#" {
                indexSectionTitles.remove(at: 0)
                indexSectionTitles.append("#")
            }
        }
        
        
        print(artistsSections)
        
        tableView.reloadData()
        
        indexView = TableViewIndex(frame: CGRect(x:view.bounds.width - 50.0,y:0,width:50.0,height:view.bounds.height))
        indexView.dataSource = self
        indexView.delegate = self
        indexView.backgroundView.backgroundColor = currentTheme.background.color.withAlphaComponent(0.9)
        view.addSubview(indexView)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        didThemeUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexSectionTitles.count
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let artists = artistsSections[indexSectionTitles[section]] {
            return artists.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexSectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexSectionTitles[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as! ArtistTableViewCell
        if let artists = artistsSections[section] {
            cell.setup(withArtist: artists[indexPath.row])
        }
        let labelX = cell.nameLabel.frame.origin.x
        cell.separatorInset = UIEdgeInsets(top: 0, left: labelX, bottom: 0, right: 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexSectionTitles[indexPath.section]
        if let artists = artistsSections[index] {
            let controller = ArtistViewController()
            controller.appleMusicManager = appleMusicManager
            controller.authorizationManager = authorizationManager
            controller.mediaLibraryManager = mediaLibraryManager
            controller.musicPlayerManager = musicPlayerManager
            controller.artist = artists[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        var views = [UIView]()
        for item in indexSectionTitles {
            let stringItem = StringItem(text: item)
            stringItem.tintColor = currentTheme.button.color
            views.append(stringItem)
        }
        return views
    }
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) -> Bool {
        let indexPath = IndexPath(row: 0, section: index)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        
        return true // return true to produce haptic feedback on capable devices
    }
}

extension ArtistsViewController: ThemeDelegate {
    func didThemeUpdate() {
        let theme = ThemeManager.currentTheme
        view.backgroundColor = theme.background.color
        tableView.backgroundColor = theme.background.color
        navigationController?.navigationBar.tintColor = theme.button.color
        navigationController?.navigationBar.barTintColor = theme.background.color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.title.color]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.title.color]
        navigationController?.navigationBar.barStyle = themeBarStyle
        tableView.separatorColor = currentTheme.detailSecondary.color
        tableView.reloadData()
        
        indexView.backgroundView.backgroundColor = currentTheme.background.color.withAlphaComponent(0.9)
        for item in indexView.items {
            if let stringItem = item as? StringItem {
                stringItem.tintColor = currentTheme.button.color
            }
        }
        
    }
}

