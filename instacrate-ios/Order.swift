//
//  Order.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class Order: Object, Decodable {
    
    dynamic var id = 0
    
    dynamic var date = Date()
    dynamic var fulfilled = false
    
    dynamic var subscription: Subscription? = nil
    dynamic var address: Shipping? = nil

    convenience init(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        date = ("url" <~~ json)!
        fulfilled = ("fulfilled" <~~ json)!
        subscription = ("subscription" <~~ json)!
        address = ("shipping" <~~ json)!
    }
}
