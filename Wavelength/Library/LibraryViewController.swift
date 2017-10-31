//
//  LibraryViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-12.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class LibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// The instance of `AuthorizationManager` used for querying and requesting authorization status.
    var authorizationManager: AuthorizationManager!
    
    /// The instance of `AppleMusicManager` which is used to make recently played item request calls to the Apple Music Web Services.
    var appleMusicManager: AppleMusicManager!
    
    /// The instance of `MusicPlayerManager` which is used for triggering the playback of a `MediaItem`.
    var musicPlayerManager: MusicPlayerManager!
    
    /// The instance of `MediaLibraryManager` which is used for adding items to the application's playlist.
    var mediaLibraryManager: MediaLibraryManager!
    
    var collectionView:UICollectionView!
    
    var recentlyAddedAlbums:[AlbumInfo] = [AlbumInfo]()
    var loading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.shadowImage = UIImage()
        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(openThemeSettings))
        navigationItem.rightBarButtonItem = settingsButton
        title = "Library"
        
        let padding:CGFloat = 18.0
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        let width = (view.frame.width - padding * 3) / 2
        layout.itemSize = CGSize(width: width, height: width * 1.26)
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        let nib = UINib(nibName: "SongCollectionViewCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: "songCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        collectionView.reloadData()
        
        mediaLibraryManager.getMusicLibrary() { albums in
            print("WE HERE")
            
            self.recentlyAddedAlbums = albums
            self.loading = false
            self.collectionView.reloadData()
        }
        
    }
    
    @objc func YAH() {
        print("YAHHAHAA")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        didThemeUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if loading { return 9 }
        return recentlyAddedAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "songCell", for: indexPath) as! SongCollectionViewCell
        if !loading {
            cell.setupAlbumItem(item: recentlyAddedAlbums[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let item = mediaItems[indexPath.row]
        //delegate?.playMedia(item: item)
        if loading { return }
        let controller = AlbumViewController()
        controller.musicPlayerManager = musicPlayerManager
        controller.album = recentlyAddedAlbums[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @objc func openThemeSettings() {
        let controller = ThemesViewController()
        let nav = UINavigationController(rootViewController: controller)
        self.present(nav, animated: true, completion: nil)
    }
    
}

extension LibraryViewController: ThemeDelegate {
    func didThemeUpdate() {
        let theme = ThemeManager.currentTheme
        view.backgroundColor = theme.background.color
        navigationController?.navigationBar.tintColor = theme.button.color
        navigationController?.navigationBar.barTintColor = theme.background.color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.title.color]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.title.color]
        collectionView.reloadData()
    }
}
