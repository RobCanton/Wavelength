//
//  MusicPlayerView.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-12.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AVFoundation

class MusicPlayerView:UIView, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaImageContainer: UIView!
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaArtistAlbumButton: UIButton!
    @IBOutlet weak var previousButton: MusicPlayerButton!
    @IBOutlet weak var playButton: MusicPlayerButton!
    @IBOutlet weak var nextButton: MusicPlayerButton!
    
    @IBOutlet weak var trackContainer: UIView!
    @IBOutlet weak var trackProgressBar: UIView!
    @IBOutlet weak var trackElapsedLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    @IBOutlet weak var elapsedLabelTop: NSLayoutConstraint!
    @IBOutlet weak var durationLabelTop: NSLayoutConstraint!
    @IBOutlet weak var volumeSlider: CustomSlider!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var divider1: UIView!
    @IBOutlet weak var divider2: UIView!
    @IBOutlet weak var upNextView: UIView!
    @IBOutlet weak var upNextLabel: UILabel!
    
    var progressTrack:UIView!
    var progressBallContainer:UIView!
    var progressBall:UIView!
    var progressBallWhite:UIView!
    var isScrubbing = false
    let labelWidth:CGFloat = 50.0
    var scrubPosition = TrackScrubPosition.left
    
    weak var delegate:WaveTableHeaderDelegate?
    
    weak var appleMusicManager:AppleMusicManager?
    weak var authorizationManager:AuthorizationManager?
    
    weak var mediaItem:MediaItem?
    func setupViews() {
        self.layoutIfNeeded()
        
        
        repeatButton.layer.cornerRadius = 8.0
        repeatButton.clipsToBounds = true
        
        shuffleButton.layer.cornerRadius = 8.0
        shuffleButton.clipsToBounds = true
        
        mediaImageView.layer.cornerRadius = 8.0
        mediaImageView.clipsToBounds = true
        mediaImageContainer.applyShadow(radius: 6.0, opacity: 0.12, height: 2.0, shouldRasterize: false)
        
        trackProgressBar.layer.cornerRadius = trackProgressBar.frame.height / 2
        trackProgressBar.clipsToBounds = true
        
        progressBallContainer = UIView(frame: CGRect(x: 0, y: 0, width: trackContainer.bounds.height * 2.0, height: trackContainer.bounds.height))
        //progressBallContainer.backgroundColor = primaryColor
        
        progressTrack = UIView(frame: trackProgressBar.bounds)
        progressTrack.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        progressTrack.center = CGPoint(x: -trackProgressBar.bounds.width / 2, y: progressTrack.center.y)
        trackProgressBar.addSubview(progressTrack)
        
        progressBallWhite = UIView(frame: CGRect(x: 0, y: 0, width: 6.0, height: 6.0))
        
        progressBallWhite.layer.cornerRadius = progressBallWhite.frame.height / 2
        progressBallWhite.clipsToBounds = true
        progressBallWhite.center = progressBallContainer.center
        progressBallContainer.addSubview(progressBallWhite)
        
        progressBall = UIView(frame: CGRect(x: 0, y: 0, width: 6.0, height: 6.0))
        progressBall.layer.cornerRadius = progressBall.frame.height / 2
        progressBall.clipsToBounds = true
        progressBall.center = progressBallContainer.center
        progressBallContainer.addSubview(progressBall)
        progressBallContainer.center = CGPoint(x: 0, y: trackContainer.bounds.height / 2)
        trackContainer.addSubview(progressBallContainer)
        //trackContainer.translatesAutoresizingMaskIntoConstraints = true
        
        playButton.setup()
        nextButton.setup()
        previousButton.setup()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(sliderDragged))
        progressBallContainer.addGestureRecognizer(gesture)
        progressBallContainer.isUserInteractionEnabled = true
        gesture.delegate = self
        
        
        volumeSlider.addTarget(self, action: #selector(didBeginSlidingVolume), for: .touchDown)
        volumeSlider.addTarget(self, action: #selector(didEndSlidingVolume), for: [.touchUpInside,.touchUpOutside])
        
        setTheme()
        
        observeVolume(true)
    }
    
    func cleanup() {
        observeVolume(false)
    }
    
    func observeVolume(_ isObserving:Bool) {
        if isObserving {
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        } else {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")

        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            guard let dict = change, let temp = dict[NSKeyValueChangeKey.newKey] as? Float else { return }
            let slider = volumeSlider as? UISlider
            slider?.setValue(temp, animated: true)
        }
    }
    
    func setTheme() {
        let theme = ThemeManager.currentTheme
        backgroundColor = theme.background.color
        mediaTitleLabel.textColor = theme.title.color
        mediaArtistAlbumButton.setTitleColor(theme.button.color, for: .normal)
        progressTrack.backgroundColor = theme.detailPrimary.color
        progressBall.backgroundColor = theme.detailPrimary.color
        progressBallWhite.backgroundColor = theme.background.color
        trackProgressBar.backgroundColor = theme.detailSecondary.color
        trackElapsedLabel.textColor = theme.detailPrimary.color
        trackDurationLabel.textColor = theme.detailPrimary.color
        
        playButton.tintColor = theme.musicBarButton.color
        nextButton.tintColor = theme.musicBarButton.color
        previousButton.tintColor = theme.musicBarButton.color
        
        volumeSlider.minimumTrackTintColor = theme.detailPrimary.color
        volumeSlider.maximumTrackTintColor = theme.detailSecondary.color
        
        shuffleButton.tintColor = theme.button.color
        repeatButton.tintColor = theme.button.color
        shuffleButton.setTitleColor(theme.button.color, for: .normal)
        repeatButton.setTitleColor(theme.button.color, for: .normal)
        shuffleButton.backgroundColor = theme.buttonBackground.color
        repeatButton.backgroundColor = theme.buttonBackground.color
        
        divider1.backgroundColor = theme.detailSecondary.color
        divider2.backgroundColor = theme.detailSecondary.color
        
        upNextLabel.textColor = theme.title.color
    }
    
    func setupMediaItem(_ item: MPMediaItem, isPlaying:Bool) {
        if let image = item.artwork?.image(at: mediaImageView.frame.size) {
            mediaImageView.image = image
        } else if let manager = appleMusicManager, let auth = authorizationManager {
            mediaImageView.image = nil
            manager.performSongRequest(songID: item.playbackStoreID, countryCode: auth.cloudServiceStorefrontCountryCode) { _item in
                DispatchQueue.main.async {
                    if let mediaItem = _item {
                        let imageURL = mediaItem.artwork.imageURL(size: self.mediaImageView.frame.size)
                        fetchMediaImageCheckingCache(url: imageURL) { url, image in
                            if imageURL.absoluteString == url {
                                self.mediaImageView.image = image
                            }
                        }
                    }
                }
            }
        } else {
            mediaImageView.image = nil
        }
        
        mediaTitleLabel.text = item.title
        
        let artistName = item.artist
        let albumTitle = item.albumTitle
        
        if artistName != nil && albumTitle == nil {
            mediaArtistAlbumButton.setTitle(artistName!, for: .normal)
        } else if artistName == nil && albumTitle != nil {
            mediaArtistAlbumButton.setTitle(albumTitle!, for: .normal)
        } else if artistName != nil && albumTitle != nil {
            mediaArtistAlbumButton.setTitle("\(artistName!) — \(albumTitle!)", for: .normal)
        } else {
            mediaArtistAlbumButton.setTitle("Unknown", for: .normal)
        }
        
        if isPlaying {
            playButton.setImage(UIImage(named: "pause_large"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "play_large"), for: .normal)
        }
    }
    
    func getTimeLabelFromInterval(time:TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        } else {
            return "\(minutes):\(seconds)"
        }
    }
    
    func setTrackPosition(trackDuration:TimeInterval, trackElapsed _trackElapsed:TimeInterval) {
        var trackElapsed:TimeInterval = 0.0
        if !_trackElapsed.isNaN {
            trackElapsed = _trackElapsed
        }
        let progress:CGFloat = CGFloat(trackElapsed) / CGFloat(trackDuration)
        
        if !isScrubbing {
            progressBallContainer.center = CGPoint(x: trackContainer.bounds.width * progress, y: trackContainer.bounds.height / 2)
            progressTrack.center = CGPoint(x: progressBallContainer.center.x - progressTrack.bounds.width / 2, y: progressTrack.center.y)
        }
    }
    
    func setTrackLabels(trackDuration:TimeInterval, trackElapsed:TimeInterval) {
        trackDurationLabel.text = "-\(getTimeLabelFromInterval(time: trackDuration - trackElapsed))"
        trackElapsedLabel.text = "\(getTimeLabelFromInterval(time: trackElapsed))"
    }
    
    @objc func sliderDragged(_ gesture:UIPanGestureRecognizer) {
        let translation = gesture.translation(in: trackContainer)
        //print("Translation: \(translation.x)")
        
        switch gesture.state {
        case .began:
            isScrubbing = true
            delegate?.trackingScrubbingChanged(true)
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                self.progressBallWhite.transform = CGAffineTransform(scaleX: 5.25, y: 5.25)
                self.progressBall.transform = CGAffineTransform(scaleX: 4.5, y: 4.5)
                self.progressBall.backgroundColor = currentTheme.button.color
                self.progressTrack.backgroundColor = currentTheme.button.color
            }, completion: { _ in })
            
            let xPos = progressBallContainer.center.x
            if xPos < labelWidth {
                scrubPosition = .left
                self.elapsedLabelTop.constant = 4.0
                self.durationLabelTop.constant = -6.0
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                    self.layoutIfNeeded()
                }, completion: { _ in })
            } else if xPos > labelWidth && xPos < trackContainer.bounds.width - labelWidth {
                scrubPosition = .center
                self.elapsedLabelTop.constant = -6.0
                self.durationLabelTop.constant = -6.0
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                    self.layoutIfNeeded()
                }, completion: { _ in })
            } else if xPos > trackContainer.bounds.width - labelWidth {
                scrubPosition = .right
                self.elapsedLabelTop.constant = -6.0
                self.durationLabelTop.constant = 4.0
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                    self.layoutIfNeeded()
                }, completion: { _ in })
            }
            
            break
        case .changed:
            var newX = progressBallContainer.center.x + translation.x
            if newX < 0.0 {
                newX = 0.0
            }
            
            if newX > trackContainer.bounds.width {
                newX = trackContainer.bounds.width
            }
            
            progressBallContainer.center = CGPoint(x: newX, y: progressBallContainer.center.y)
            progressTrack.center = CGPoint(x: progressBallContainer.center.x - progressTrack.bounds.width / 2, y: progressTrack.center.y)
            gesture.setTranslation(CGPoint.zero, in: trackContainer)
            
            if newX < labelWidth && scrubPosition != .left {
                scrubPosition = .left
                self.elapsedLabelTop.constant = 4.0
                self.durationLabelTop.constant = -6.0
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                    self.layoutIfNeeded()
                }, completion: { _ in })
            } else if newX > labelWidth && newX < trackContainer.bounds.width - labelWidth && scrubPosition != .center {
                scrubPosition = .center
                self.elapsedLabelTop.constant = -6.0
                self.durationLabelTop.constant = -6.0
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                    self.layoutIfNeeded()
                }, completion: { _ in })
            } else if newX > trackContainer.bounds.width - labelWidth && scrubPosition != .right {
                scrubPosition = .right
                self.elapsedLabelTop.constant = -6.0
                self.durationLabelTop.constant = 4.0
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                    self.layoutIfNeeded()
                }, completion: { _ in })
            }
            break
        case .ended:
            isScrubbing = false
            delegate?.trackingScrubbingChanged(false)
            delegate?.setTrack(currentProgress: progressBallContainer.center.x / trackContainer.bounds.width)
            self.elapsedLabelTop.constant = -6.0
            self.durationLabelTop.constant = -6.0
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                self.progressBallWhite.transform = CGAffineTransform.identity
                self.progressBall.transform = CGAffineTransform.identity
                self.progressBall.backgroundColor = currentTheme.detailPrimary.color
                self.progressTrack.backgroundColor = currentTheme.detailPrimary.color
                self.layoutIfNeeded()
            }, completion: { _ in })
            break
        default:
            isScrubbing = false
            delegate?.trackingScrubbingChanged(false)
            self.elapsedLabelTop.constant = -6.0
            self.durationLabelTop.constant = -6.0
            UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                self.progressBallWhite.transform = CGAffineTransform.identity
                self.progressBall.transform = CGAffineTransform.identity
                self.progressBall.backgroundColor = currentTheme.detailPrimary.color
                self.progressTrack.backgroundColor = currentTheme.detailPrimary.color
                self.layoutIfNeeded()
            }, completion: { _ in })
            break
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: self)
            return fabs(velocity.x) > fabs(velocity.y)
        }
        return true
    }
    
    @IBAction func handleArtistAlbumButton(_ sender: Any) {
        print("handleArtistAlbumButton")
        delegate?.showArtistAlbum()
    }
    
    @IBAction func handlePlayButton(_ sender: Any) {
        playButton.animateTap()
        delegate?.playTrack()
    }
    
    @IBAction func handleNextButton(_ sender: Any) {
        nextButton.animateTap()
        delegate?.nextTrack()
    }
    
    @IBAction func handlePreviousButton(_ sender: Any) {
        previousButton.animateTap()
        delegate?.previousTrack()
    }
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(sender.value, animated: true)
    }
    
    @objc func didBeginSlidingVolume() {
        delegate?.volumeSliderChanged(true)
    }
    
    @objc func didEndSlidingVolume() {
        delegate?.volumeSliderChanged(false)
    }
}

protocol WaveTableHeaderDelegate:class {
    func trackingScrubbingChanged(_ isScrubbing:Bool)
    func setTrack(currentProgress progress:CGFloat)
    
    func showArtistAlbum()
    func playTrack()
    func nextTrack()
    func previousTrack()
    func volumeSliderChanged(_ isSliding:Bool)
}
