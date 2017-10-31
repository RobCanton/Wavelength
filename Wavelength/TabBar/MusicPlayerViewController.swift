//
//  MusicPlayerViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-12.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

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

class MusicPlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    
    let cellIdentifier = "commentCell"
    var header:MusicPlayerView!
    
    weak var musicPlayerManager:MusicPlayerManager?
    var mediaItem:MPMediaItem!
    
    var tableView:UITableView!
    
    var isKeyboardUp = false
    
    var containerScrollView:UIScrollView!
    
    
    var comments = [Comment]()
    
    let headerHeight:CGFloat = UIScreen.main.bounds.height
    
    let commentHeight:CGFloat = 44.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        containerScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        containerScrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        
        view.addSubview(containerScrollView)
        tableView = UITableView(frame: CGRect(x: 0, y: headerHeight, width: view.bounds.width, height: view.bounds.height - headerHeight - commentHeight - 20.0 - 8.0), style: .plain)
        
        let nib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        header = UINib(nibName: "MusicPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MusicPlayerView
        //header.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)
        //header.setupViews()
        containerScrollView.addSubview(header)
        
        if let manager = musicPlayerManager {
            header.setupMediaItem(mediaItem, isPlaying: manager.isPlaying)
        }
        
        //header.delegate = self
        tableView.tableHeaderView = UIView()//header
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 8.0))
        tableView.separatorColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        containerScrollView.addSubview(tableView)
        tableView.reloadData()

    }
    
    deinit {
        musicPlayerManager = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMusicPlayerManagerDidUpdateState),
                                               name: MusicPlayerManager.didUpdateState,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTrackPositionChanged),
                                               name: MusicPlayerManager.trackPositionChanged,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let staticHeight:CGFloat = 3 + 3 + 8 + 8 + 16
        let staticWidth:CGFloat = 6 + 6 + 12 + 30 + 8
        let variableWidth:CGFloat = tableView.frame.width - staticWidth
        let text = comments[indexPath.row].text
        let size = UILabel.size(withText: text, forWidth: variableWidth, withFont: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.regular))
        return size.height + staticHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommentTableViewCell
        cell.setup(withComment: comments[indexPath.row])
        let labelX = cell.infoContainerView.frame.origin.x
        
        cell.separatorInset = UIEdgeInsetsMake(0, labelX, 0, 0)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.isEqual(containerScrollView) else {
            return
        }
        
        
        if scrollView.contentOffset.y > 0 || isKeyboardUp {
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
        guard scrollView.isEqual(containerScrollView) else {
            return
        }
        
        scrollView.bounces = true
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.isEqual(tableView) {
            containerScrollView.bounces = false
            deckTransitionDelegate?.isDismissEnabled = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.isEqual(tableView) {
            containerScrollView.bounces = true
            deckTransitionDelegate?.isDismissEnabled = true
        }
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
    
    
    @objc func handleTrackPositionChanged() {
        
        guard let manager = musicPlayerManager else { return }
        guard let nowPlayingItem = manager.musicPlayerController.nowPlayingItem else { return }
        DispatchQueue.main.async {
            //self.header.setTrackPosition(trackDuration: nowPlayingItem.playbackDuration, trackElapsed: manager.musicPlayerController.currentPlaybackTime)
        }
    }
    
    @objc func handleMusicPlayerManagerDidUpdateState() {
        DispatchQueue.main.async {
            
            if let manager = self.musicPlayerManager {
                if let nowPlayingItem = manager.musicPlayerController.nowPlayingItem {
                    self.mediaItem = nowPlayingItem
                    self.comments = []
                    self.tableView.reloadData()
                    self.self.header.setupMediaItem(self.mediaItem, isPlaying: manager.isPlaying)
                }
            }
        }
    }
    
    func scrollBottom(animated:Bool) {
        if comments.count > 0 {
            let lastIndex = IndexPath(row: comments.count-1, section: 0)
            self.tableView.scrollToRow(at: lastIndex, at: UITableViewScrollPosition.bottom, animated: animated)
        }
    }
    
}

extension MusicPlayerViewController: WaveTableHeaderDelegate {
    func setTrack(currentProgress progress: CGFloat) {
        print("Set progress: \(progress)")
        guard let manager = musicPlayerManager else { return }
        guard let item = manager.musicPlayerController.nowPlayingItem else { return }
        manager.musicPlayerController.currentPlaybackTime = TimeInterval(progress) * item.playbackDuration
    }
    
    func trackingScrubbingChanged(_ isScrubbing: Bool) {
        deckTransitionDelegate?.isDismissEnabled = !isScrubbing
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
}

extension MusicPlayerViewController: DeckTransitionDestinationDelegate {
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
        header.mediaImageView.isHidden = true
        resignFirstResponder()
    }
    
    func transitionDidEnd(forward: Bool) {
        header.mediaImageView.isHidden = false
        if forward {
            becomeFirstResponder()
        }
    }
    
    
}

