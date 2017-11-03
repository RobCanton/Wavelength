//
//  Song.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-11-03.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import MediaPlayer

class Song {
    
    private(set) var id:String
    private(set) var name:String
    private(set) var artistName:String
    private(set) var nameExcludingCommonPrefixes:String
    private(set) var artwork:MPMediaItemArtwork?

    
    
    init(id: String, name:String, artistName:String? = nil, artwork:MPMediaItemArtwork?) {
        self.id = id
        self.name = name
        self.artistName = artistName != nil  ? artistName! : "?"
        self.artwork = artwork
        
        nameExcludingCommonPrefixes = self.artistName
        let prefixes = ["The ", "A ", "An ", "'", "\"", "(", "$"]
        for prefix in prefixes {
            if self.artistName.characters.count > prefix.characters.count {
                let subIndex = self.artistName.index(name.startIndex, offsetBy: prefix.characters.count)
                let substring = self.artistName.substring(to: subIndex)
                if substring.localizedCaseInsensitiveCompare(prefix) == .orderedSame {
                    nameExcludingCommonPrefixes = self.artistName.substring(from: subIndex)
                }
            }
        }
    }
    
}
