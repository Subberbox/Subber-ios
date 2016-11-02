//
//  File.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class Box: BaseObject {
    
    dynamic var id = 0

    dynamic var name = ""
    dynamic var brief = ""
    dynamic var long_desc = ""
    dynamic var short_desc = ""
    dynamic var bullets: String = ""
    dynamic var freq = ""
    dynamic var price = 0.0
    dynamic var publish_date = Date()
    
    let categories = List<Category>()
    dynamic var vendor: Vendor?
    
    let pictures = LinkingObjects(fromType: Picture.self, property: "box")
    let reviews = LinkingObjects(fromType: Review.self, property: "box")
    let subscriptions = LinkingObjects(fromType: Subscription.self, property: "box")
    
    convenience required init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        name = ("name" <~~ json)!
        brief = ("brief" <~~ json)!
        long_desc = ("long_desc" <~~ json)!
        short_desc = ("short_desc" <~~ json)!
        
        if let bullets: [String] = "bullets" <~~ json, let first = bullets.first {
            self.bullets = first
        }
        
        freq = ("freq" <~~ json)!
        price = ("price" <~~ json)!
        vendor = "vendor" <~~ json
//        publish_date = try Date(timeIntervalSince1970: TimeInterval(node.extract("publish_date") as Int))
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
