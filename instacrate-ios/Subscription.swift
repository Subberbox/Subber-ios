//
//  Subscription.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class Subscription: Object, Decodable {
    
    dynamic var id = 0

    dynamic var date = Date()
    dynamic var active = true
    
    dynamic var box: Box? = nil
    dynamic var address: Shipping? = nil
    
    let orders = LinkingObjects(fromType: Order.self, property: "subscription")
    
    convenience init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        date = ("date" <~~ json)!
        active = ("active" <~~ json)!
        box = ("box" <~~ json)!
    }
}
