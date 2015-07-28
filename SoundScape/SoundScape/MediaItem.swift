/*

Copyright (c) 2014 Samsung Electronics

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

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


