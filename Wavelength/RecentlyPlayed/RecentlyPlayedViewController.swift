//
//  RecentlyPlayedViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-04.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class RecentlyPlayedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// The instance of `AuthorizationManager` used for querying and requesting authorization status.
    var authorizationManager: AuthorizationManager!
    
    /// The instance of `AppleMusicManager` which is used to make recently played item request calls to the Apple Music Web Services.
    var appleMusicManager: AppleMusicManager!
    
    /// The instance of `ImageCacheManager` that is used for downloading and caching album artwork images.
    let imageCacheManager = ImageCacheManager()
    
    /// The instance of `MusicPlayerManager` which is used for triggering the playback of a `MediaItem`.
    var musicPlayerManager: MusicPlayerManager!
    
    /// The instance of `MediaLibraryManager` which is used for adding items to the application's playlist.
    var mediaLibraryManager: MediaLibraryManager!
    
    /// The array of `MediaItem` objects that represents the list of search results.
    var mediaItems = [MediaItem]() {
        didSet {
            tableView.reloadData()
            print("Recent Items: \(mediaItems)")
        }
    }
    
    var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "songCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if appleMusicManager.fetchDeveloperToken() == nil {
            
            let alertController = UIAlertController(title: "Error",
                                                    message: "No Developer Token was specified. See the README for more information.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else if authorizationManager.userToken == "" {
            let alertController = UIAlertController(title: "Error",
                                                    message: "No User Token was specified. Request Authorization using the \"Authorization\" tab.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {
            refreshData()
        }
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        return cell
    }
    
    // MARK: Notification Observer Callback Methods.
    
    func handleMediaLibraryManagerLibraryDidUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func refreshData() {
        appleMusicManager.performAppleMusicGetRecentlyPlayed(userToken: authorizationManager.userToken) { [weak self] (mediaItems, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    
                    // Your application should handle these errors appropriately depending on the kind of error.
                    
                    self?.mediaItems = []
                    
                    let alertController: UIAlertController
                    
                    guard let error = error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
                        
                        alertController = UIAlertController(title: "Error",
                                                            message: "Encountered unexpected error.",
                                                            preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        
                        DispatchQueue.main.async {
                            self?.present(alertController, animated: true, completion: nil)
                        }
                        
                        return
                    }
                    
                    alertController = UIAlertController(title: "Error",
                                                        message: underlyingError.localizedDescription,
                                                        preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    
                    DispatchQueue.main.async {
                        self?.present(alertController, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                self?.mediaItems = mediaItems
            }
        }
    }
}



