//
//  Picture.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class Picture: Object, Decodable {
    
    dynamic var id = 0
    dynamic var url = ""
    
    dynamic var box: Box? = nil
    
    convenience init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        url = ("url" <~~ json)!
        box = ("box" <~~ json)!
    }
}
