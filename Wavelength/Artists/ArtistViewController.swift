//
//  ArtistViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-30.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class ArtistViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var authorizationManager: AuthorizationManager!
    var appleMusicManager: AppleMusicManager!
    var musicPlayerManager: MusicPlayerManager!
    var mediaLibraryManager: MediaLibraryManager!
    
    var artist:Artist!
//    var appleMusicManager:AppleMusicManager!
//    var authorizationManager:AuthorizationManager!
    
    var collectionView:UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = artist.name
        
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
        
        let headerNib = UINib(nibName: "LibraryHeaderView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        collectionView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didThemeUpdate()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artist.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "songCell", for: indexPath) as! SongCollectionViewCell
        cell.setupAlbumItem(item: artist.albums[indexPath.row])
        cell.setTheme()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = AlbumViewController()
        controller.album = artist.albums[indexPath.row]
        controller.musicPlayerManager = musicPlayerManager
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ArtistViewController: ThemeDelegate {
    func didThemeUpdate() {
        let theme = ThemeManager.currentTheme
        view.backgroundColor = theme.background.color
        navigationController?.navigationBar.tintColor = theme.button.color
        navigationController?.navigationBar.barTintColor = theme.background.color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.title.color]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.title.color]
        navigationController?.navigationBar.barStyle = themeBarStyle
        
        collectionView.reloadData()
    }
}
