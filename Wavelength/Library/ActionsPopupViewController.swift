//
//  ActionsPopupViewController.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-30.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class ActionsPopupViewController:UIViewController {
    
    var containerView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = nil
        containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width * 0.9, height: view.bounds.height * 8.0))
        containerView.center = view.center
        containerView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        view.addSubview(containerView)
        
    }
}
