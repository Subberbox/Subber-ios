//
//  Category.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class Category: BaseObject {
    
    dynamic var id = 0
    dynamic var name = ""
    
    let boxes = LinkingObjects(fromType: Box.self, property: "categories")
    
    convenience required init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        name = ("name" <~~ json)!
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
