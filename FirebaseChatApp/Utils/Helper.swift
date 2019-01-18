//
//  Helper.swift
//  FirebaseChatApp
//
//  Created by Ong Wei Yap on 13/1/19.
//  Copyright © 2019 Ong Wei Yap. All rights reserved.
//

import Foundation
import UIKit

class Helper { }

extension UIView {
    
    func anchorViewTo(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        anchorViewWithConstantsTo(top: top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorViewWithConstantsTo(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let tempTop = top {
            topAnchor.constraint(equalTo: tempTop, constant: topConstant).isActive = true
        }
        
        if let tempLeft = left {
            leftAnchor.constraint(equalTo: tempLeft, constant: leftConstant).isActive = true
        }
        
        if let tempBottom = bottom {
            bottomAnchor.constraint(equalTo: tempBottom, constant: -bottomConstant).isActive = true
        }
        
        if let tempRight = right {
            rightAnchor.constraint(equalTo: tempRight, constant: -rightConstant).isActive = true
        }
        
    }
    
    func anchorViewWithHeightConstant(height: CGFloat) {
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func anchorViewWithWidthConstant(width: CGFloat) {
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func anchorViewWithHeightAndWidthConstant(height: CGFloat, width: CGFloat) {
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func anchorViewWithWidthAnchorAndConstant(width: NSLayoutDimension, widthConstant: CGFloat) {
        widthAnchor.constraint(equalTo: width, constant: widthConstant).isActive = true
    }
    
    func anchorViewWithHeightAnchorAndMutiplier(height: NSLayoutDimension, multiplier: CGFloat) {
        heightAnchor.constraint(equalTo: height, multiplier: multiplier).isActive = true
    }
    
    func centerViewWithX(x: NSLayoutXAxisAnchor) {
        centerXAnchor.constraint(equalTo: x).isActive = true
    }
    
    func centerViewWithY(y: NSLayoutYAxisAnchor) {
        centerYAnchor.constraint(equalTo: y).isActive = true
    }
    
    func centerViewWithXandY(x: NSLayoutXAxisAnchor, y: NSLayoutYAxisAnchor) {
        centerXAnchor.constraint(equalTo: x).isActive = true
        centerYAnchor.constraint(equalTo: y).isActive = true
    }
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
}

let imageCache = NSCache<NSString, UIImage>()
class WyImageView: UIImageView {
    
    var imageUrlString: String?
    
    func network(urlString: String) {
        
        imageUrlString = urlString
        
        let url = URL(string: urlString)!
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print(error ?? "Network image error...")
                return
            }
            
            DispatchQueue.main.async {
                
                if let imageData = data, let imageToCache = UIImage(data: imageData) {
                    
                    if self.imageUrlString == urlString {
                        self.image = imageToCache
                    }
                    
                    imageCache.setObject(imageToCache, forKey: NSString(string: urlString))
                }
                else {
                    print("Caching image data problem...")
                }
                
            }
            
            }.resume()
    }
    
}












