//
//  MediaCollectionBannerView.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-10.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class MediaCollectionBannerView:UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mediaItems = [MediaItem]() {
        didSet {
            print("Recent Items: \(mediaItems)")
            collectionView?.reloadData()
        }
    }
    weak var delegate:SongCollectionViewProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup() {
        self.layoutIfNeeded()
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: collectionView.frame.height * 0.75, height: collectionView.frame.height)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        let nib = UINib(nibName: "SongCollectionViewCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: "songCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "songCell", for: indexPath) as! SongCollectionViewCell
        cell.setupMediaItem(item: mediaItems[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = mediaItems[indexPath.row]
        delegate?.playMedia(item: item)
        
    }
    
    
}
