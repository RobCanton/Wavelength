//
//  UIViewExtensions.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-04.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    func applyShadow(radius:CGFloat, opacity:Float, height:CGFloat, shouldRasterize:Bool) {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: height)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shouldRasterize = shouldRasterize
        
    }
    
    func applyShadow(withColor color: UIColor, radius:CGFloat, opacity:Float, height:CGFloat, shouldRasterize:Bool) {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: height)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.shouldRasterize = shouldRasterize
        
    }
    
    func cropToCircle() {
        self.layer.cornerRadius = self.frame.width/2
        self.clipsToBounds = true
    }
    
    func snapshot(of rect: CGRect? = nil) -> UIImageView? {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        guard let image = wholeImage, let rect = rect else { return nil }
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        let screenshot = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        let view = UIImageView(frame: rect)
        view.image = screenshot
        return view
    }
}

open class CustomSlider : UISlider {
    @IBInspectable open var trackWidth:CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
}

extension UIImage {
    var colorAverage: UIColor {
        get {
            var bitmap = [UInt8](repeating: 0, count: 4)
            
            if #available(iOS 9.0, *) {
                // Get average color.
                let context = CIContext()
                let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
                let extent = inputImage.extent
                let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
                let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
                let outputImage = filter.outputImage!
                let outputExtent = outputImage.extent
                assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
                
                // Render to bitmap.
                context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
            } else {
                // Create 1x1 context that interpolates pixels when drawing to it.
                let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
                let inputImage = cgImage ?? CIContext().createCGImage(ciImage!, from: ciImage!.extent)
                
                // Render to bitmap.
                context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            
            // Compute result.
            let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: 1.0)
            return result
        }
        
    }
}
