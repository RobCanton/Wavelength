//
//  UIStringExtensions.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-08.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation

extension Date
{
    func timeString(withSuffix _suffix:String?) -> String
    {
        let suffix = _suffix != nil ? " \(_suffix!)" : ""
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: self, to: Date())
        
        if components.day! >= 365 {
            return "\(components.day! / 365)y\(suffix)"
        }
        
        if components.day! >= 7 {
            return "\(components.day! / 7)w\(suffix)"
        }
        
        if components.day! > 0 {
            return "\(components.day!)d\(suffix)"
        }
        else if components.hour! > 0 {
            return "\(components.hour!)h\(suffix)"
        }
        else if components.minute! > 0 {
            return "\(components.minute!)m\(suffix)"
        }
        return "\(components.second!)s\(suffix)"

    }
}
