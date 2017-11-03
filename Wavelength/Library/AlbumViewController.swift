//
//  AlbumViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-13.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class AlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    /// The instance of `MusicPlayerManager` which is used for triggering the playback of a `MediaItem`.
    var musicPlayerManager: MusicPlayerManager!
    
    var tableView:UITableView!
    var header:AlbumHeaderView!
    var footer:AlbumFooterView!

    let cellIdentifier = "songCell"
    
    var album:AlbumInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.bounds)
        
        header = UINib(nibName: "AlbumHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AlbumHeaderView
        header.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.width * (3 / 5))
        header.titleLabel.text = album.albumTitle
        header.artistButton.setTitle(album.albumArtist, for: .normal)
        header.artworkImageView.image = album.artwork?.image(at: header.artworkImageView.frame.size)
        let genre = album.genre
        let year = album.year
        if genre != nil && year == nil {
            header.subtitleLabel.text = genre
        } else if genre == nil && year != nil {
            header.subtitleLabel.text = "\(year!)"
        } else if genre != nil && year != nil {
            header.subtitleLabel.text = "\(genre!) • \(year!)"
        } else {
            header.subtitleLabel.text = ""
        }
        
        header.delegate = self
        
        let nib = UINib(nibName: "AlbumSongTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableHeaderView = header
        footer = UINib(nibName: "AlbumFooterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AlbumFooterView
        footer.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 260.0)
        
        let numSongs = album.songs.count
        if numSongs == 1 {
            footer.label.text = "1 song"
        } else {
            footer.label.text = "\(numSongs) songs"
        }
        //footer.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tableView.tableFooterView = footer
        tableView.separatorColor = ThemeManager.currentTheme.detailSecondary.color
        view.addSubview(tableView)
        tableView.reloadData()
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == .began {
            
            let touchPoint = longPressGestureRecognizer.location(in: view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print(indexPath)
                // your code here, get the row for the indexPath or do whatever you want
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        didThemeUpdate()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMusicPlayerManagerDidUpdateState),
                                               name: MusicPlayerManager.didUpdateState,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMusicPlayerManagerNowPlayingChanged),
                                               name: MusicPlayerManager.nowPlayingChanged,
                                               object: nil)
        
        musicManagerDidUpdateState()
        nowPlayingChanged()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album.songs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AlbumSongTableViewCell
        let song = album.songs[indexPath.row]
        
        cell.setup(title: song.title, number: song.albumTrackNumber)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let splitArray = Array(album.songs[indexPath.row..<album.songs.count])
        musicPlayerManager.beginPlayback(queue: splitArray)
//
//        if let cell = tableView.cellForRow(at: indexPath) as? SongTableViewCell {
//            cell.setMusicIndicatorState(.playing)
//        }
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    
    var currentlyPlayingIndex:IndexPath?
    
    func nowPlayingChanged() {
        if let nowPlayingItem = musicPlayerManager.musicPlayerController.nowPlayingItem {
            for i in 0..<album.songs.count {
                let song = album.songs[i]
                if song.persistentID == nowPlayingItem.persistentID {
                    
                    if let currentIndex = currentlyPlayingIndex {
                        if i != currentIndex.row {
                            if let cell = tableView.cellForRow(at: currentIndex) as? AlbumSongTableViewCell {
                                cell.setMusicIndicatorState(.stopped)
                            }
                        }
                    }
                    let newIndexPath = IndexPath(row: i, section: 0)
                    currentlyPlayingIndex = newIndexPath
                    musicManagerDidUpdateState()
                    break
                }
            }
        } else {
            if let currentIndex = currentlyPlayingIndex {
                if let cell = tableView.cellForRow(at: currentIndex) as? AlbumSongTableViewCell {
                    cell.setMusicIndicatorState(.stopped)
                }
            }
        }
    }
    
    func musicManagerDidUpdateState() {
        guard let currentIndex = currentlyPlayingIndex else { return }
        if let cell = tableView.cellForRow(at: currentIndex) as? AlbumSongTableViewCell {
            if musicPlayerManager.isPlaying {
                cell.setMusicIndicatorState(.playing)
            } else {
                cell.setMusicIndicatorState(.paused)
            }
        }
    }
    
}

extension AlbumViewController: ThemeDelegate {
    func didThemeUpdate() {
        let theme = ThemeManager.currentTheme
        view.backgroundColor = theme.background.color
        tableView.backgroundColor = theme.background.color
        navigationController?.navigationBar.tintColor = theme.button.color
        navigationController?.navigationBar.barTintColor = theme.background.color
        header.setTheme()
        footer.setTheme()
        tableView.reloadData()
    }
}

extension AlbumViewController: AlbumHeaderProtocol {
    func playAlbum() {
        print("playAlbum")
        
        musicPlayerManager.beginPlayback(queue: album.songs)
    }
    
    func shuffleAlbum() {
        var songs = album.songs
        songs.shuffle()
        musicPlayerManager.beginPlayback(queue: songs)
        print("shuffleAlbum")
    }
    
    func showArtist() {
        guard let tab = tabBarController as? MainTabBarController else { return }
        let artistController = ArtistViewController()
//        print("artistCode: \(album.albumArtistID)")
//        artistController.artistID = album.albumArtist
//        artistController.appleMusicManager = tab.appleMusicManager
//        artistController.authorizationManager = tab.authorizationManager
//        navigationController?.pushViewController(artistController, animated: true)
    }
}

//Without this import line, you'll get compiler errors when implementing your touch methods since they aren't part of the UIGestureRecognizer superclass
//Without this import line, you'll get compiler errors when implementing your touch methods since they aren't part of the UIGestureRecognizer superclass
import UIKit.UIGestureRecognizerSubclass

//Since 3D Touch isn't available before iOS 9, we can use the availability APIs to ensure no one uses this class for earlier versions of the OS.
@available(iOS 9.0, *)
public class ForceTouchGestureRecognizer: UIGestureRecognizer {
    //Because we don't know what the maximum force will always be for a UITouch, the force property here will be normalized to a value between 0.0 and 1.0.
    public private(set) var force: CGFloat = 0.0
    public var maximumForce: CGFloat = 4.0
    
    convenience init() {
        self.init(target: nil, action: nil)
    }
    
    //We override the initializer because UIGestureRecognizer's cancelsTouchesInView property is true by default. If you were to, say, add this recognizer to a tableView's cell, it would prevent didSelectRowAtIndexPath from getting called. Thanks for finding this bug, Jordan Hipwell!
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        normalizeForceAndFireEvent(.began, touches: touches)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        normalizeForceAndFireEvent(.changed, touches: touches)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        normalizeForceAndFireEvent(.ended, touches: touches)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        normalizeForceAndFireEvent(.cancelled, touches: touches)
    }
    
    private func normalizeForceAndFireEvent(_ state: UIGestureRecognizerState, touches: Set<UITouch>) {
        //Putting a guard statement here to make sure we don't fire off our target's selector event if a touch doesn't exist to begin with.
        guard let firstTouch = touches.first else { return }
        
        //Just in case the developer set a maximumForce that is higher than the touch's maximumPossibleForce, I'm setting the maximumForce to the lower of the two values.
        maximumForce = min(firstTouch.maximumPossibleForce, maximumForce)
        
        //Now that I have a proper maximumForce, I'm going to use that and normalize it so the developer can use a value between 0.0 and 1.0.
        force = firstTouch.force / maximumForce
        
        //Our properties are now ready for inspection by the developer. By setting the UIGestureRecognizer's state property, the system will automatically send the target the selector message that this recognizer was initialized with.
        self.state = state
        print("YUH")
        print(state)
    }
    
    //This function is called automatically by UIGestureRecognizer when our state is set to .Ended. We want to use this function to reset our internal state.
    public override func reset() {
        super.reset()
        force = 0.0
    }
}
