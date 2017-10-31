//
//  CommentTableViewCell.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-06.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    //@IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var roundBubbleView: UIView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var activeDotContainer: UIView!
    @IBOutlet weak var activeDot: UIView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var bubbleTrailing: NSLayoutConstraint!
    
    var comment:Comment!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
        
        activeDot.layer.cornerRadius = activeDot.frame.width / 2
        activeDot.clipsToBounds = true
        
        roundBubbleView.layer.cornerRadius = 24.0
        roundBubbleView.clipsToBounds = true
        //roundBubbleView.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        //roundBubbleView.layer.borderWidth = 1.0
        
        //bubbleView.applyShadow(radius: 3.0, opacity: 0.10, height: 0.0, shouldRasterize: false)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    let staticWidth:CGFloat = 6 + 12 + 30 + 8 + 12 + 6
    
    func setup(withComment comment:Comment) {
        usernameLabel.text = comment.username
        commentLabel.text = comment.text
        timeLabel.text = comment.timestamp.timeString(withSuffix: nil)
        self.layoutIfNeeded()
        
        let labelSize = UILabel.size(withText: comment.text, forHeight: 18.0, withFont: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.regular)).width
        let variableWidth = self.bounds.width - staticWidth
        print("Text: \(comment.text) | LabelSize: \(labelSize) | variableWidth: \(variableWidth)")
        let maxWidth:CGFloat = self.frame.width - (6 + 12 + 30 + 8 + infoStackView.frame.width + 6)
        if (labelSize < variableWidth) {
            let constant = variableWidth - labelSize
            if constant < maxWidth {
               bubbleTrailing.constant = variableWidth - labelSize
            } else {
                bubbleTrailing.constant = maxWidth - 6.0
            }
            
        } else {
            bubbleTrailing.constant = 6
        }
        
        self.layoutIfNeeded()
        
    }
    
}
