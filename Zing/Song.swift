//
//  Song.swift
//  Zing
//
//  Created by iOS Student on 11/25/16.
//  Copyright © 2016 Duong. All rights reserved.
//

import Foundation
import UIKit

struct Song {
    var title = ""
    var artistName = ""
    var thumbnail: UIImage
    var sourceOnline = ""
    var sourceLocal = ""
    let baseThumbnail = "http://image.mp3.zdn.vn//thumb/240_240/"
    var localThumbnail = ""
    
    init(title: String, artistName: String, thumbnail: String, source: String) {
        self.title = title
        self.artistName = artistName
        let thumbnailURL = baseThumbnail + thumbnail
        let dataImage = try? Data(contentsOf: URL(string: thumbnailURL)!)
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceOnline = source
    }
    
    init(title: String, artistName: String, localThumbnail: String, localSource: String) {
        self.title = title
        self.artistName = artistName
        self.localThumbnail = localThumbnail
        let dataImage = try? Data(contentsOf: URL(fileURLWithPath: self.localThumbnail))
        self.thumbnail = UIImage(data: dataImage!)!
        self.sourceLocal = localSource
    }
}
