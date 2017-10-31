//
//  MainTabBarController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-04.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire
import DeckTransition
import MediaPlayer

class MainTabBarController: UITabBarController {

    /// The instance of `AuthorizationManager` which is responsible for managing authorization for the application.
    lazy var authorizationManager: AuthorizationManager = {
        return AuthorizationManager(appleMusicManager: self.appleMusicManager)
    }()
    
    /// The instance of `MediaLibraryManager` which manages the `MPPMediaPlaylist` this application creates.
    lazy var mediaLibraryManager: MediaLibraryManager = {
        return MediaLibraryManager(authorizationManager: self.authorizationManager)
    }()
    
    /// The instance of `AppleMusicManager` which handles making web service calls to Apple Music Web Services.
    var appleMusicManager = AppleMusicManager()
    
    /// The instance of `MusicPlayerManager` which handles media playback.
    var musicPlayerManager = MusicPlayerManager()
    
    var currentMediaItemID:String?
    
    var playerBar:MusicPlayerBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        playerBar = UINib(nibName: "MusicPlayerBar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MusicPlayerBar
        playerBar.frame = CGRect(x: 0, y: view.bounds.height - tabBar.frame.height - 68.0, width: view.bounds.width, height: 68.0)
        playerBar.setupViews()
        playerBar.delegate = self
        view.insertSubview(playerBar, belowSubview: tabBar)
        setMusicBarHidden(true, animated: false)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentMusicChatView))
        playerBar.addGestureRecognizer(tap)
        playerBar.isUserInteractionEnabled = true
        
        guard let homeScreen = viewController(atIndex: 0) as? LibraryViewController else {
            fatalError("homeScreen not found at index 0")
        }
        
        guard let searchScreen = viewController(atIndex: 1) as? SearchViewController else {
            fatalError("homeScreen not found at index 0")
        }
        
        homeScreen.authorizationManager = authorizationManager
        homeScreen.appleMusicManager = appleMusicManager
        homeScreen.musicPlayerManager = musicPlayerManager
        homeScreen.mediaLibraryManager = mediaLibraryManager
        
        searchScreen.authorizationManager = authorizationManager
        searchScreen.appleMusicManager = appleMusicManager
        searchScreen.musicPlayerManager = musicPlayerManager
        searchScreen.mediaLibraryManager = mediaLibraryManager
        // Add the notification observer needed to respond to events from the `MusicPlayerManager`.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMusicPlayerManagerDidUpdateState),
                                               name: MusicPlayerManager.didUpdateState,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMusicPlayerManagerNowPlayingChanged),
                                               name: MusicPlayerManager.nowPlayingChanged,
                                               object: nil)
        nowPlayingChanged()
        musicManagerDidUpdateState()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.dismiss(animated: false, completion: nil)
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didThemeUpdate()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didThemeUpdate),
                                               name: ThemeManager.didThemeUpdate,
                                               object: nil)
    }
    
    var albumIDToPresent:MPMediaEntityPersistentID?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if albumIDToPresent != nil {
            mediaLibraryManager.getAlbum(albumIDToPresent!) { album in
                if album != nil {
                    print("HERE!")
                    let albumController = AlbumViewController()
                    albumController.album = album!
                    albumController.musicPlayerManager = self.musicPlayerManager
                    if let nav = self.selectedViewController as? UINavigationController {
                        nav.pushViewController(albumController, animated: true)
                    }
                }
            }
            albumIDToPresent = nil
        }
    }
    
    @objc func handleMusicPlayerManagerNowPlayingChanged() {
        DispatchQueue.main.async {
            self.nowPlayingChanged()
        }
    }
    
    @objc func handleMusicPlayerManagerDidUpdateState() {
        DispatchQueue.main.async {
            self.musicManagerDidUpdateState()
        }
    }
    
    func setMusicBarHidden(_ hidden:Bool, animated: Bool) {
        var offScreenFrame = playerBar.frame
        if hidden {
            offScreenFrame.origin.y = view.bounds.height - tabBar.bounds.height
        } else {
            offScreenFrame.origin.y = view.bounds.height - tabBar.bounds.height - playerBar.bounds.height
        }
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
                self.playerBar.frame = offScreenFrame
            }, completion: { _ in })
        } else {
            self.playerBar.frame = offScreenFrame
        }
    }
    
    func nowPlayingChanged() {
        if let nowPlayingItem = musicPlayerManager.musicPlayerController.nowPlayingItem {
            let isLibraryItem = mediaLibraryManager.isSongInLibrary(nowPlayingItem.persistentID)
            print("isLibraryItem: \(isLibraryItem)")
            print("nowPlayingItem: \(nowPlayingItem)")
            playerBar.setupMediaItem(item: nowPlayingItem)
            setMusicBarHidden(false, animated: true)
            
        } else {
            setMusicBarHidden(true, animated: true)
            print("No Playing Item");
            
        }
    }
    
    func musicManagerDidUpdateState() {
        if musicPlayerManager.musicPlayerController.playbackState == .playing {
            playerBar.playButton.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            playerBar.playButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    var deckTransitionDelegate = DeckTransitioningDelegate()
    
    @objc func presentMusicChatView() {
        guard let  nowPlayingItem = musicPlayerManager.musicPlayerController.nowPlayingItem else { return }
        let modal = ChatRoomViewController()
        modal.mediaItem = nowPlayingItem
        modal.musicPlayerManager = musicPlayerManager
        modal.transitioningDelegate = deckTransitionDelegate
        modal.modalPresentationStyle = .custom
        guard let controller = selectedViewController as? UINavigationController else { return }
        controller.navigationBar.barStyle = .black
        present(modal, animated: true, completion: nil)
    }
    
    func viewController(atIndex index: Int) -> UIViewController? {

       guard let navigationController = viewControllers?[index] as? UINavigationController else {
                fatalError("Unable to find expected View Controller in Main.storyboard.")
        }

        return navigationController.topViewController
    }
    
}

extension MainTabBarController: MusicPlayerBarProtocol {
    func playMedia() {
        musicPlayerManager.togglePlayPause()
    }
    
    func skipMedia() {
        musicPlayerManager.skipToNextItem()
    }
}

extension MainTabBarController: DeckTransitionSourceDelegate {
    
    func transitionSourceImageCornerRadius() -> CGFloat {
        return playerBar.mediaImageView.layer.cornerRadius
    }
    
    func transitionSourceImage() -> UIImage? {
        return playerBar.mediaImageView.image
    }
    
    func transitionSourceImageFrame() -> CGRect {
        return playerBar.mediaImageView.convert(playerBar.mediaImageView.frame, to: view)
    }
    
    func message() -> String {
        return "Eminem is a great rapper"
    }
    
    func transitionWillBegin(forward:Bool) {
        //playerBar.mediaImageView.isHidden = true
        playerBar.blurView.isHidden = true
        playerBar.isHidden = true
    }
    
    func transitionDidEnd(forward: Bool) {
        //playerBar.mediaImageView.isHidden = false
        playerBar.blurView.isHidden = false
        playerBar.isHidden = false
    }
    
    func transitionSourceTabBarSnapshot() -> UIImageView {
        let snapshot = tabBar.snapshot(of: tabBar.bounds)
        return snapshot!
    }
    
    func transitionSourceBarView() -> UIView{
        let bar = UIView(frame: playerBar.bounds)
        bar.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.0)
        let label = UILabel(frame: playerBar.mediaTitleView.frame)
        label.text = playerBar.mediaTitleView.text
        label.font = playerBar.mediaTitleView.font
        label.textColor = playerBar.mediaTitleView.textColor
        bar.addSubview(label)
        
        let playButton = UIButton(frame: playerBar.playButton.frame)
        playButton.setImage(playerBar.playButton.imageView!.image, for: .normal)
        playButton.tintColor = playerBar.playButton.tintColor
        bar.addSubview(playButton)
        
        let nextButton = UIButton(frame: playerBar.skipButton.frame)
        nextButton.setImage(playerBar.skipButton.imageView!.image, for: .normal)
        nextButton.tintColor = playerBar.skipButton.tintColor
        bar.addSubview(nextButton)
        
        return bar
    }
    
    func transitionSourceBlurView() -> [String:Any] {
        let dict:[String:Any] = [
            "colorTint": playerBar.blurView.colorTint!,
            "colorTintAlpha": playerBar.blurView.colorTintAlpha,
            "blurRadius": playerBar.blurView.blurRadius,
            "scale": playerBar.blurView.scale
        ]
        return dict
    }
    
}

extension MainTabBarController: ThemeDelegate {
    @objc func didThemeUpdate() {
        tabBar.barTintColor = currentTheme.background.color
        tabBar.tintColor = currentTheme.button.color
        playerBar.setTheme()
        if let controller = selectedViewController as? UINavigationController {
            controller.navigationBar.barStyle = themeBarStyle
        }
    }
}
