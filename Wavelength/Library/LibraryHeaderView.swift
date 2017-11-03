//
//  LibraryHeaderView.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-11-02.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

protocol LibraryHeaderDelegate:class {
    func showArtists()
    func showSongs()
}

class LibraryHeaderView: UICollectionReusableView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recentlyAddedLabel: UILabel!
    
    weak var delegate:LibraryHeaderDelegate?
    let tableCellHeight:CGFloat = 54.0
    let titles = [
        "Playlists",
        "Artists",
        "Albums",
        "Songs"
        
    ]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup() {
        let nib = UINib(nibName: "LibraryHeaderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "titleCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = currentTheme.detailSecondary.color
        recentlyAddedLabel.textColor = currentTheme.title.color
        tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! LibraryHeaderTableViewCell
        cell.titleLabel.text = titles[indexPath.row]
        cell.titleLabel.textColor = currentTheme.button.color
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            delegate?.showArtists()
            break
        case 2:
            break
        case 3:
            delegate?.showSongs()
            break
        default:
            break
        }
    }
}
