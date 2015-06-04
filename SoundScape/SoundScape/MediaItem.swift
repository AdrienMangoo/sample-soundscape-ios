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


