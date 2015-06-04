//
//  UIImage+Helpers.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 6/2/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import Foundation

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func imageWithStringColor(colorString: String) -> UIImage {
        let color = colorString.stringToColor()
        return imageWithColor(color)
    }
}