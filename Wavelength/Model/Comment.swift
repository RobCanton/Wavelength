//
//  Comment.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-06.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import Foundation
import Firebase

protocol DocumentSerializable {
    init?(dictionary:[String:Any])
}

struct Comment {
    var author:String
    var username:String
    var text:String
    var timestamp:Date
    

}

extension Comment : DocumentSerializable {
    init?(dictionary: [String: Any]) {
        
        guard let author = dictionary["author"] as? String,
            let username = dictionary["username"] as? String,
            let text = dictionary["text"] as? String,
            let timestamp = dictionary["timestamp"] as? Date else { return nil }
        
        self.init(author: author, username: username, text: text, timestamp: timestamp)
    
    }
}
