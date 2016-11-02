//
//  Shipping.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class Shipping: BaseObject {
    
    dynamic var id = 0
    
    dynamic var address = ""
    dynamic var appartment = ""
    
    dynamic var city = ""
    dynamic var state = ""
    dynamic var zip = ""
    
    dynamic var user: User? = nil
    
    convenience required init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        user = ("user" <~~ json)!
        
        address = ("address" <~~ json)!
        appartment = ("appartment" <~~ json)!
        
        city = ("city" <~~ json)!
        state = ("state" <~~ json)!
        zip = ("zip" <~~ json)!
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
