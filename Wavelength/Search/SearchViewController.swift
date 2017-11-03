//
//  SearchViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-24.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

enum SearchMode {
    case appleMusic, yourLibrary
}
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// The instance of `AuthorizationManager` used for querying and requesting authorization status.
    var authorizationManager: AuthorizationManager!
    /// The instance of `AppleMusicManager` which is used to make search request calls to the Apple Music Web Services.
    var appleMusicManager: AppleMusicManager!
    /// The instance of `MusicPlayerManager` which is used for triggering the playback of a `MediaItem`.
    var musicPlayerManager: MusicPlayerManager!
    /// The instance of `MediaLibraryManager` which is used for adding items to the application's playlist.
    var mediaLibraryManager: MediaLibraryManager!
    
    /// The instance of `ImageCacheManager` that is used for downloading and caching album artwork images.
    let imageCacheManager = ImageCacheManager()
    
    var tableView:UITableView!
    var header:SearchTableHeaderView!
    var searchMode = SearchMode.yourLibrary
    var searchController:UISearchController!
    
    var songResults = [MPMediaItem]()
    var appleMusicMediaItems = [[MediaItem]]() {
        didSet {
            DispatchQueue.main.async {
                print("AppleMusicItems: \(self.appleMusicMediaItems)")
                self.tableView.reloadData()
            }
        }
    }
    
    /// A `DispatchQueue` used for synchornizing the setting of `mediaItems` to avoid threading issues with various `UITableView` delegate callbacks.
    var setterQueue = DispatchQueue(label: "MediaSearchTableViewController")
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        navigationController?.navigationBar.shadowImage = UIImage()

        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Your Library"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        let nib = UINib(nibName: "SearchSongTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "songCell")
        header = UINib(nibName: "SearchTableHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SearchTableHeaderView
        header.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width,height: 54.0)
        tableView.tableHeaderView = header
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        header.segmentedControl.selectedSegmentIndex = 1
        header.segmentedControl.addTarget(self, action: #selector(handleSegmentedControl), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        didThemeUpdate()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.keyboardAppearance = themeKeyboardType
        
    }
    
    @objc func handleSegmentedControl(_ target:UISegmentedControl) {
        if target.selectedSegmentIndex == 0 {
            searchMode = .appleMusic
            searchController.searchBar.placeholder = "Apple Music"
        } else {
            searchMode = .yourLibrary
            searchController.searchBar.placeholder = "Your Library"
        }
        print("searchMode: \(searchMode)")
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch searchMode {
        case .appleMusic:
            return appleMusicMediaItems.count
        case .yourLibrary:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchMode {
        case .appleMusic:
            return appleMusicMediaItems[section].count
        case .yourLibrary:
            return songResults.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SearchSongTableViewCell
        switch searchMode {
        case .appleMusic:
            let mediaItem = appleMusicMediaItems[indexPath.section][indexPath.row]
            cell.setItem(mediaItem)
            
            // Image loading.
            let imageURL = mediaItem.artwork.imageURL(size: CGSize(width: 90, height: 90))
            print("ImageURL: \(imageURL)")
            if let image = imageCacheManager.cachedImage(url: imageURL) {
                // Cached: set immediately.
                
                cell.artworkImageView.image = image
                cell.artworkImageView.alpha = 1
            } else {
                // Not cached, so load then fade it in.
                cell.artworkImageView.alpha = 0
                
                imageCacheManager.fetchImage(url: imageURL, completion: { (image) in
                    // Check the cell hasn't recycled while loading.
                    
                    if (cell.mediaItem?.identifier ?? "") == mediaItem.identifier {
                        cell.artworkImageView.image = image
                        UIView.animate(withDuration: 0.3) {
                            cell.artworkImageView.alpha = 1
                        }
                    }
                })
            }
            
            break
        case .yourLibrary:
            cell.setItem(songResults[indexPath.row])
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch searchMode {
        case .appleMusic:
            let song = appleMusicMediaItems[0][indexPath.row]
            
            searchController.searchBar.endEditing(true)
            musicPlayerManager.beginPlayback(queueIDs: [song.identifier])
            break
        case .yourLibrary:
            let song = songResults[indexPath.row]
            searchController.searchBar.endEditing(true)
            musicPlayerManager.beginPlayback(queue: [song])
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        guard let text = searchController.searchBar.text else { return }
        if searchMode == .appleMusic {
            if text == "" {
                self.setterQueue.sync {
                    self.appleMusicMediaItems = []
                }
            } else {
                print("SEARCHING WITH: \(text)")
                appleMusicManager.performAppleMusicCatalogSearch(with: text,
                                                                 countryCode: authorizationManager.cloudServiceStorefrontCountryCode,
                                                                 completion: { [weak self] (searchResults, error) in
                    guard error == nil else {
                        
                        // Your application should handle these errors appropriately depending on the kind of error.
                        self?.setterQueue.sync {
                            self?.appleMusicMediaItems = []
                        }
                        print("ERROR!")
                        
                        return
                    }
                    
                    self?.setterQueue.sync {
                        print("SYNC!")
                        self?.appleMusicMediaItems = searchResults
                    }
                                                                    
                })
            }
        } else {
            if text == "" {
                songResults = []
            } else {
                songResults = mediaLibraryManager.searchMusicLibrarySongs(with: text)
            }
            tableView.reloadData()
        }
        
    }
}

extension SearchViewController: ThemeDelegate {
    func didThemeUpdate() {
        let theme = ThemeManager.currentTheme
        view.backgroundColor = theme.background.color
        tableView.backgroundColor = theme.background.color
        navigationController?.navigationBar.tintColor = theme.button.color
        navigationController?.navigationBar.barTintColor = theme.background.color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.title.color]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.title.color]
        navigationController?.navigationBar.barStyle = themeBarStyle
        searchController.searchBar.tintColor = theme.button.color
        searchController.searchBar.textColor = theme.title.color
        header.segmentedControl.tintColor = theme.button.color
        header.backgroundColor = theme.background.color
        tableView.reloadData()
    }
}

extension UISearchBar {
    
    var textColor:UIColor? {
        get {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                return textField.textColor
            } else {
                return nil
            }
        }
        
        set (newValue) {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                textField.textColor = newValue
            }
        }
    }
}
