//
//  ImageManager.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-10.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit




let imageCache = NSCache<NSString, UIImage>()

func loadImageUsingCacheWithURL(_ _url:String, completion: @escaping (_ image:UIImage?, _ fromCache:Bool)->()) {
    // Check for cached image
    if let cachedImage = imageCache.object(forKey: _url as NSString) {
        return completion(cachedImage, true)
    } else {
        downloadImageWithURLString(_url, completion: completion)
    }
}

func loadImageCheckingCache(withUrl _url:String, id:String, completion: @escaping (_ image:UIImage?, _ fromCache:Bool, _ id:String)->()) {
    // Check for cached image
    if let cachedImage = imageCache.object(forKey: _url as NSString) {
        return completion(cachedImage, true, id)
    } else {
        downloadImage(withUrl: _url, id: id, completion: completion)
    }
}

func downloadImageWithURLString(_ _url:String, completion: @escaping (_ image:UIImage?, _ fromCache:Bool)->()) {
    
    let url = URL(string: _url)
    
    URLSession.shared.dataTask(with: url!, completionHandler:
        { (data, response, error) in
            
            //error
            if error != nil {
                if error?._code == -999 {
                    return
                }
                //print(error?.code)
                return completion(nil, false)
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: _url as NSString)
                }
                
                let image = UIImage(data: data!)
                return completion(image, false)
            }
            
    }).resume()
}

func downloadImage(withUrl _url:String, id:String, completion: @escaping (_ image:UIImage?, _ fromCache:Bool, _ id:String)->()) {
    
    let url = URL(string: _url)
    
    URLSession.shared.dataTask(with: url!, completionHandler:
        { (data, response, error) in
            
            //error
            if error != nil {
                if error?._code == -999 {
                    return
                }
                //print(error?.code)
                return completion(nil, false, id)
            }
            DispatchQueue.main.async {
                if let d = data, let downloadedImage = UIImage(data: d) {
                    imageCache.setObject(downloadedImage, forKey: _url as NSString)
                    return completion(downloadedImage, false, id)
                }
                return completion(nil, false, id)
                
            }
            
    }).resume()
}
