//
//  String+Helpers.swift
//  SoundScape
//
//  Created by Prasath Thurgam on 6/2/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

import Foundation
import MSF

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

extension Service {
    public var displayName: String {
        var displayName = name.stringByReplacingOccurrencesOfString("[TV] ", withString: "") as String
        return displayName
    }
    
}