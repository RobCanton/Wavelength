//
//  Artist.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-11-02.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import MediaPlayer

class Artist {
    
    private(set) var id:String
    private(set) var name:String
    private(set) var nameExcludingCommonPrefixes:String
    private(set) var artwork:MPMediaItemArtwork?
    private(set) var albums:[AlbumInfo]
    
    
    init(id: String, name:String, artwork:MPMediaItemArtwork?, albums:[AlbumInfo]? = nil) {
        self.id = id
        self.name = name
        self.artwork = artwork
        self.albums = albums != nil ? albums! : []
        
        nameExcludingCommonPrefixes = self.name
        let prefixes = ["The ", "A ", "An ", "'", "\"", "("]
        for prefix in prefixes {
            if name.characters.count > prefix.characters.count {
                let subIndex = name.index(name.startIndex, offsetBy: prefix.characters.count)
                let substring = name.substring(to: subIndex)
                if substring.localizedCaseInsensitiveCompare(prefix) == .orderedSame {
                    nameExcludingCommonPrefixes = name.substring(from: subIndex)
                }
            }
        }
    }
    
    func addAlbum(_ album:AlbumInfo) {
        albums.append(album)
    }
    
}
