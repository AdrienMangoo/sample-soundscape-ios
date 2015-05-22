//
//  MediaItem.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 5/13/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import Foundation
import UIKit

class MediaItem: NSObject {
    var artist: String?
    var name: String?
    var title: String?
    var fileURL: String?
    var albumArtURL: String?
    var thumbnailURL: String?
    var id: String?
    var duration: Int?
    var color: String?
    init(artist: String?, name: String?, title: String?, fileURL: String?, albumArtURL: String?, thumbnailURL: String?, id: String?, duration: Int?, color: String?) {
        self.artist = artist
        self.name = name
        self.title = title
        self.fileURL = fileURL
        self.albumArtURL = albumArtURL
        self.thumbnailURL = thumbnailURL
        self.id = id
        self.duration = duration
        self.color = color
    }
}

extension String {
    func URLEncodedString() -> String? {
        var customAllowedSet =  NSCharacterSet.URLQueryAllowedCharacterSet()
        
        var escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)

        return escapedString
    }
    
    func stringToColor() -> UIColor {
        var temp = self.stringByReplacingOccurrencesOfString("#", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var hexInt: UInt32 = 0
        let scanner = NSScanner(string: temp)
        scanner.scanHexInt(&hexInt)
        let color = UIColor(
            red: CGFloat((hexInt & 0xFF0000) >> 16)/225,
            green: CGFloat((hexInt & 0xFF00) >> 8)/225,
            blue: CGFloat((hexInt & 0xFF))/225,
            alpha: 1)
        
        return color
    }
    func endsWith (str: String) -> Bool {
        if let range = self.rangeOfString(str) {
            return range.endIndex == self.endIndex
        }
        return false
    }
}

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