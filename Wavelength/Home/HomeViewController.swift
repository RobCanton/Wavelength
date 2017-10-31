//
//  ViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-04.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer
import Firebase

class ViewController: UIViewController {

//    /// The instance of `AuthorizationManager` used for querying and requesting authorization status.
//    var authorizationManager: AuthorizationManager!
//
//    /// The instance of `AppleMusicManager` which is used to make recently played item request calls to the Apple Music Web Services.
//    var appleMusicManager: AppleMusicManager!
//
//    /// The instance of `MusicPlayerManager` which is used for triggering the playback of a `MediaItem`.
//    var musicPlayerManager: MusicPlayerManager!
//
//    let cellIdentifier = "songCell"
//    var tableView:UITableView!
//    /// The array of `MediaItem` objects that represents the list of search results.
//    var mediaItems = [MediaItem]() {
//        didSet {
//            recentlyPlayedBannerView?.mediaItems = mediaItems
//        }
//    }
//
//    var recentlyPlayedBannerView: MediaCollectionBannerView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        // Add the notification observers needed to respond to events from the `AuthorizationManager` and `UIApplication`.
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.prefersLargeTitles = true
//        title = "Library"
//        tableView = UITableView(frame: view.bounds, style: .plain)
//        let nib = UINib(nibName: "SongTableViewCell", bundle: nil)
//
//        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
//        tableView.delegate = self
//        tableView.dataSource = self
//
//        recentlyPlayedBannerView = UINib(nibName: "MediaCollectionBannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MediaCollectionBannerView
//        recentlyPlayedBannerView.frame = CGRect(x:0,y:0,width:tableView.frame.width,height: 220.0)
//        recentlyPlayedBannerView.setup()
//        recentlyPlayedBannerView.delegate = self
//        tableView.tableHeaderView = recentlyPlayedBannerView
//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120.0))
//        view.addSubview(tableView)
//        let notificationCenter = NotificationCenter.default
//
//        notificationCenter.addObserver(self,
//                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
//                                       name: AuthorizationManager.cloudServiceDidUpdateNotification,
//                                       object: nil)
//
//        notificationCenter.addObserver(self,
//                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
//                                       name: AuthorizationManager.authorizationDidUpdateNotification,
//                                       object: nil)
//
//        notificationCenter.addObserver(self,
//                                       selector: #selector(handleAuthorizationManagerDidUpdateNotification),
//                                       name: .UIApplicationWillEnterForeground,
//                                       object: nil)
//
//
//        setAuthorizationRequestButtonState()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        setAuthorizationRequestButtonState()
//
//        if appleMusicManager.fetchDeveloperToken() == nil {
//
//            let alertController = UIAlertController(title: "Error",
//                                                    message: "No Developer Token was specified. See the README for more information.",
//                                                    preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
//            present(alertController, animated: true, completion: nil)
//        } else if authorizationManager.userToken == "" {
//            let alertController = UIAlertController(title: "Error",
//                                                    message: "No User Token was specified. Request Authorization using the \"Authorization\" tab.",
//                                                    preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
//            present(alertController, animated: true, completion: nil)
//        } else {
//            refreshData()
//        }
//    }
//
//    func refreshData() {
//        appleMusicManager.performAppleMusicGetRecentlyPlayed(userToken: authorizationManager.userToken) { [weak self] (mediaItems, error) in
//            DispatchQueue.main.async {
//                guard error == nil else {
//
//                    // Your application should handle these errors appropriately depending on the kind of error.
//
//                    self?.mediaItems = []
//
//                    let alertController: UIAlertController
//
//                    guard let error = error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error else {
//
//                        alertController = UIAlertController(title: "Error",
//                                                            message: "Encountered unexpected error.",
//                                                            preferredStyle: .alert)
//                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//
//                        DispatchQueue.main.async {
//                            self?.present(alertController, animated: true, completion: nil)
//                        }
//
//                        return
//                    }
//
//                    alertController = UIAlertController(title: "Error",
//                                                        message: underlyingError.localizedDescription,
//                                                        preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//
//                    DispatchQueue.main.async {
//                        self?.present(alertController, animated: true, completion: nil)
//                    }
//
//                    return
//                }
//
//                self?.mediaItems = mediaItems
//            }
//        }
//    }
//
//    deinit {
//        // Remove all notification observers.
//        let notificationCenter = NotificationCenter.default
//
//        notificationCenter.removeObserver(self,
//                                          name: AuthorizationManager.cloudServiceDidUpdateNotification,
//                                          object: nil)
//        notificationCenter.removeObserver(self,
//                                          name: AuthorizationManager.authorizationDidUpdateNotification,
//                                          object: nil)
//        notificationCenter.removeObserver(self,
//                                          name: .UIApplicationWillEnterForeground,
//                                          object: nil)
//    }
//
//    func setAuthorizationRequestButtonState() {
//        if SKCloudServiceController.authorizationStatus() == .notDetermined || MPMediaLibrary.authorizationStatus() == .notDetermined {
//            self.navigationItem.rightBarButtonItem?.isEnabled = true
//        } else {
//            self.navigationItem.rightBarButtonItem?.isEnabled = false
//        }
//    }
//
//    @IBAction func requestAuthorization(_ sender: Any) {
//        authorizationManager.requestCloudServiceAuthorization()
//
//        authorizationManager.requestMediaLibraryAuthorization()
//
//    }
//
//    @objc func handleAuthorizationManagerDidUpdateNotification() {
//        DispatchQueue.main.async {
//            if SKCloudServiceController.authorizationStatus() == .notDetermined || MPMediaLibrary.authorizationStatus() == .notDetermined {
//                self.navigationItem.rightBarButtonItem?.isEnabled = true
//                print("Music unauthorized")
//            } else {
//                self.navigationItem.rightBarButtonItem?.isEnabled = false
//                print("Music authorized")
//                if self.authorizationManager.cloudServiceCapabilities.contains(.musicCatalogSubscriptionEligible) &&
//                    !self.authorizationManager.cloudServiceCapabilities.contains(.musicCatalogPlayback) {
//                    //self.presentCloudServiceSetup()
//                }
//
//            }
//
//            DispatchQueue.main.async {
//                //self.tableView.reloadData()
//            }
//        }
//    }
//
//    @IBAction func handleLogout(_ sender: Any) {
//        try! Auth.auth().signOut()
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        get {
//            return .default
//        }
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 9
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 96
//        }
//        return 64
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SongTableViewCell
//        let labelX = cell.songTitleLabel.frame.origin.x
//        cell.separatorInset = UIEdgeInsetsMake(0, labelX, 0, 0)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
}
//
//extension ViewController: SongCollectionViewProtocol {
//    func playMedia(item: MediaItem) {
//        musicPlayerManager.beginPlayback(itemID: item.identifier)
//    }
//}

