//
//  WaveTableHeader.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-05.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import MediaPlayer

enum TrackScrubPosition {
    case left, center, right
}

class WaveTableHeader: UIView, UIGestureRecognizerDelegate {

    @IBOutlet weak var mediaImageContainerView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaTitleView: UILabel!
    @IBOutlet weak var mediaSubtitleView: UILabel!
    @IBOutlet weak var skipBackButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var trackContainer: UIView!
    @IBOutlet weak var trackProgressBar: UIView!
    @IBOutlet weak var trackElapsedLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    @IBOutlet weak var elapsedLabelTop: NSLayoutConstraint!
    @IBOutlet weak var durationLabelTop: NSLayoutConstraint!
    
    var progressTrack:UIView!
    var progressBallContainer:UIView!
    var progressBall:UIView!
    var progressBallWhite:UIView!
    var isScrubbing = false
    let labelWidth:CGFloat = 50.0
    var scrubPosition = TrackScrubPosition.left
    
    weak var delegate:WaveTableHeaderDelegate?
    
    func setupViews() {
        mediaImageContainerView.applyShadow(radius: 6.0, opacity: 0.12, height: 2.0, shouldRasterize: false)
        mediaImageView.layer.cornerRadius = 4.0
        mediaImageView.clipsToBounds = true
        
        trackProgressBar.layer.cornerRadius = trackProgressBar.frame.height
        trackProgressBar.clipsToBounds = true
        
        progressBallContainer = UIView(frame: CGRect(x: 0, y: 0, width: trackContainer.bounds.height * 2.0, height: trackContainer.bounds.height))
        //progressBallContainer.backgroundColor = primaryColor
        
        progressTrack = UIView(frame: trackProgressBar.bounds)
        progressTrack.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        progressTrack.center = CGPoint(x: -trackProgressBar.bounds.width / 2, y: progressTrack.center.y)
        trackProgressBar.addSubview(progressTrack)
        
        progressBallWhite = UIView(frame: CGRect(x: 0, y: 0, width: 6.0, height: 6.0))
        progressBallWhite.backgroundColor = UIColor.white
        progressBallWhite.layer.cornerRadius = progressBallWhite.frame.height / 2
        progressBallWhite.clipsToBounds = true
        progressBallWhite.center = progressBallContainer.center
        progressBallContainer.addSubview(progressBallWhite)
        
        progressBall = UIView(frame: CGRect(x: 0, y: 0, width: 6.0, height: 6.0))
        progressBall.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        progressBall.layer.cornerRadius = progressBall.frame.height / 2
        progressBall.clipsToBounds = true
        progressBall.center = progressBallContainer.center
        progressBallContainer.addSubview(progressBall)
        progressBallContainer.center = CGPoint(x: 0, y: trackContainer.bounds.height / 2)
        trackContainer.addSubview(progressBallContainer)
        //trackContainer.translatesAutoresizingMaskIntoConstraints = true
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(sliderDragged))
        progressBallContainer.addGestureRecognizer(gesture)
        progressBallContainer.isUserInteractionEnabled = true
        gesture.delegate = self
        
        print("GESTURE SET!")
        
    }
    
    func setupMediaItem(_ item: MPMediaItem, isPlaying:Bool) {
        
        mediaImageView.image = item.artwork?.image(at: mediaImageView.frame.size)
        mediaTitleView.text = item.title
        
        let artistName = item.artist
        let albumTitle = item.albumTitle
        
        if artistName != nil && albumTitle == nil {
            mediaSubtitleView.text = artistName!
        } else if artistName == nil && albumTitle != nil {
            mediaSubtitleView.text = albumTitle!
        } else if artistName != nil && albumTitle != nil {
            mediaSubtitleView.text = "\(artistName!) — \(albumTitle!)"
        } else {
            mediaSubtitleView.text = "Unknown Artist or Album"
        }
        
        if isPlaying {
            playButton.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "play"), for: .normal)
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
    
    func setTrackPosition(trackDuration:TimeInterval, trackElapsed:TimeInterval) {

        trackDurationLabel.text = "-\(getTimeLabelFromInterval(time: trackDuration - trackElapsed))"
        trackElapsedLabel.text = "\(getTimeLabelFromInterval(time: trackElapsed))"
        
        let progress:CGFloat = CGFloat(trackElapsed) / CGFloat(trackDuration)
        //print("PROGRESS: \(progress)")
        if !isScrubbing {
            progressBallContainer.center = CGPoint(x: trackContainer.bounds.width * progress, y: trackContainer.bounds.height / 2)
            progressTrack.center = CGPoint(x: progressBallContainer.center.x - progressTrack.bounds.width / 2, y: progressTrack.center.y)
        }
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
                self.progressBall.backgroundColor = accentColor
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
                self.progressBall.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
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
                self.progressBall.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
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
    
    @IBAction func handlePlayButton(_ sender: Any) {
        delegate?.playTrack()
    }
    
    @IBAction func handleNextButton(_ sender: Any) {
        delegate?.nextTrack()
    }
    
    @IBAction func handlePreviousButton(_ sender: Any) {
        delegate?.previousTrack()
    }
    
}
