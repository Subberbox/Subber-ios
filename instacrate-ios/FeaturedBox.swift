//
//  FeaturedBox.swift
//  subber-api
//
//  Created by Hakon Hanesand on 10/12/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class FeaturedBox: BaseObject {
    
    dynamic var id = 0
    dynamic var box: Box? = nil
    
    convenience required init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        box = ("box" <~~ json)!
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}