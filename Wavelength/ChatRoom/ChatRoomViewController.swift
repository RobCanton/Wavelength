//
//  ChatRoomViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-05.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import DeckTransition
import StoreKit
import MediaPlayer
import Firebase

class ChatRoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    let cellIdentifier = "queueCell"
    var header:MusicPlayerView!
    
    weak var appleMusicManager:AppleMusicManager?
    weak var authorizationManager:AuthorizationManager?
    weak var musicPlayerManager:MusicPlayerManager?
    var mediaItem:MPMediaItem!
    var tableView:UITableView!
    var isKeyboardUp = false

    var queue = [MPMediaItem]()
    var comments = [Comment]()
    let headerHeight:CGFloat = UIScreen.main.bounds.height + 44.0 - 20.0 - 8.0
    var shouldScrollToTop = false
    var timer:Timer!
    var slowTimer:Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: CGRect(x: 0, y: 0.0, width: view.bounds.width, height: view.bounds.height - 20.0 - 8.0), style: .plain)
        
        let nib = UINib(nibName: "QueueTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        header = UINib(nibName: "MusicPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MusicPlayerView
        header.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)
        header.appleMusicManager = appleMusicManager
        header.authorizationManager = authorizationManager
        header.setupViews()
        header.delegate = self
    
        
        if let manager = musicPlayerManager {
            header.setupMediaItem(mediaItem, isPlaying: manager.isPlaying)
            //queue = manager.queue
        }
        
        //header.delegate = self
        tableView.tableHeaderView = header
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 8.0))
        footer.backgroundColor = nil
        tableView.tableFooterView = footer
        tableView.separatorColor = UIColor.lightGray
        tableView.separatorStyle = .none
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        view.addSubview(tableView)
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMusicPlayerManagerDidUpdateState),
                                               name: MusicPlayerManager.didUpdateState,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMusicPlayerManagerNowPlayingChanged),
                                               name: MusicPlayerManager.nowPlayingChanged,
                                               object: nil)
    }

    deinit {
        musicPlayerManager = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VolumeBar.sharedInstance.backgroundColor = UIColor.black
        VolumeBar.sharedInstance.tintColor = UIColor.white
        VolumeBar.sharedInstance.trackTintColor = UIColor.gray
        
        setNeedsStatusBarAppearanceUpdate()
        
        updateMusicTimeProgress()
        updateMusicTimeLabels()
        didThemeUpdate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateMusicTimeProgress), userInfo: nil, repeats: true)
        //timer.fire()
        //RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        //RunLoop.current.add(timer, forMode: .commonModes)
        
        slowTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateMusicTimeLabels), userInfo: nil, repeats: true)
        //RunLoop.main.add(slowTimer, forMode: RunLoopMode.commonModes)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        header.cleanup()
        timer?.invalidate()
        slowTimer?.invalidate()
        
        VolumeBar.sharedInstance.backgroundColor = currentTheme.background.color
        VolumeBar.sharedInstance.tintColor = currentTheme.detailPrimary.color
        VolumeBar.sharedInstance.trackTintColor = currentTheme.detailSecondary.color
    }
    
    @objc func updateMusicTimeProgress() {
        guard let manager = musicPlayerManager else { return }
        guard let nowPlayingItem = manager.musicPlayerController.nowPlayingItem else { return }
        DispatchQueue.main.async {
        self.header.setTrackPosition(trackDuration: nowPlayingItem.playbackDuration, trackElapsed: manager.musicPlayerController.currentPlaybackTime)
        }
    }
    
    @objc func updateMusicTimeLabels() {
        guard let manager = musicPlayerManager else { return }
        guard let nowPlayingItem = manager.musicPlayerController.nowPlayingItem else { return }
        self.header.setTrackLabels(trackDuration: nowPlayingItem.playbackDuration, trackElapsed: manager.musicPlayerController.currentPlaybackTime)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! QueueTableViewCell
        //cell.setItem(queue[indexPath.row])
        cell.separatorInset = UIEdgeInsetsMake(0, cell.titleLabel.frame.origin.x, 0, 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let manager = musicPlayerManager else { return }
        //let splitArray = Array(queue[indexPath.row..<queue.count])
        //shouldScrollToTop = true
        //manager.beginPlayback(queue: splitArray)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //let movedObject = self.queue[sourceIndexPath.row]
        //queue.remove(at: sourceIndexPath.row)
        //queue.insert(movedObject, at: destinationIndexPath.row)
        // To check for correctness enable: self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
   
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y > 0 {
            // Normal behaviour if the `scrollView` isn't scrolled to the top
            scrollView.bounces = true
            deckTransitionDelegate?.isDismissEnabled = false
        } else {
            if scrollView.isDecelerating {

            } else {
                // If the user has panned to the top, the scrollview doesnʼt bounce and
                // the dismiss gesture is enabled.
                scrollView.bounces = false
                deckTransitionDelegate?.isDismissEnabled = true
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.bounces = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    var deckTransitionDelegate: DeckTransitioningDelegate? {
        get {
            return transitioningDelegate as? DeckTransitioningDelegate
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

    
    func nowPlayingChanged() {
        print("nowPlayingChanged")
        if let manager = self.musicPlayerManager {
            if let nowPlayingItem = manager.musicPlayerController.nowPlayingItem {
                self.mediaItem = nowPlayingItem
                //self.queue = manager.queue
                self.tableView.reloadData()
                //print(self.mediaItem.lyrics)
                
                self.header.setupMediaItem(self.mediaItem, isPlaying: manager.isPlaying)
                
                if self.shouldScrollToTop {
                    self.tableView.setContentOffset(CGPoint.zero, animated: true)
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
        if shouldScrollToTop {
            shouldScrollToTop = false
        }
    }
    
    func musicManagerDidUpdateState() {
        guard let manager = musicPlayerManager else { return }
        if manager.isPlaying {
            header.playButton.setImage(UIImage(named: "pause_large"), for: .normal)
        } else {
            header.playButton.setImage(UIImage(named: "play_large"), for: .normal)
        }
    }
    
    func scrollBottom(animated:Bool) {
        if comments.count > 0 {
            let lastIndex = IndexPath(row: comments.count-1, section: 0)
            self.tableView.scrollToRow(at: lastIndex, at: UITableViewScrollPosition.bottom, animated: animated)
        }
    }

}

extension ChatRoomViewController: WaveTableHeaderDelegate {
    func setTrack(currentProgress progress: CGFloat) {
        print("Set progress: \(progress)")
        
        guard let manager = musicPlayerManager else { return }
        guard let item = manager.musicPlayerController.nowPlayingItem else { return }
        manager.musicPlayerController.currentPlaybackTime = TimeInterval(progress) * item.playbackDuration
    }
    
    func trackingScrubbingChanged(_ isScrubbing: Bool) {
        deckTransitionDelegate?.isDismissEnabled = !isScrubbing
    }
    
    func showArtistAlbum() {
        guard let parent = self.presentingViewController as? MainTabBarController else { return }
        parent.albumIDToPresent = mediaItem.albumPersistentID
        self.dismiss(animated: true, completion: nil)
    }
    
    func playTrack() {
        musicPlayerManager?.togglePlayPause()
    }
    
    func nextTrack() {
        musicPlayerManager?.skipToNextItem()
    }
    
    func previousTrack() {
        musicPlayerManager?.skipBackToBeginningOrPreviousItem()
    }
    
    func volumeSliderChanged(_ isSliding:Bool) {
        deckTransitionDelegate?.isDismissEnabled = isSliding
    }
}

extension ChatRoomViewController: DeckTransitionDestinationDelegate {
    func transitionDestinationImage() -> UIImage? {
        return header.mediaImageView.image
    }
    
    func transitionDestinationImageFrame() -> CGRect {
        return header.mediaImageView.convert(header.mediaImageView.frame, to: view)
    }
    
    func transitionSourceImageCornerRadius() -> CGFloat {
        return header.mediaImageView.layer.cornerRadius
    }
    
    func funnymessage() -> String {
        return "Eminem is a great rapper"
    }
    
    func transitionWillBegin(forward:Bool) {
        header.mediaImageContainer.isHidden = true

    }
    
    func transitionDidEnd(forward: Bool) {
        header.mediaImageContainer.isHidden = false
    }
    
    
}

extension ChatRoomViewController: ThemeDelegate {
    func didThemeUpdate() {
        let theme = ThemeManager.currentTheme
        view.backgroundColor = theme.background.color
        tableView.backgroundColor = theme.background.color
        tableView.tintColor = theme.background.color
        header.setTheme()
        tableView.reloadData()
    }
}
