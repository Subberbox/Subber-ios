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

final class User: BaseObject {
    
    dynamic var id: Int = 0
    
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var stripe_id: String?
    
    let reviews = LinkingObjects(fromType: Review.self, property: "user")
    let sessions = LinkingObjects(fromType: Session.self, property: "user")
    let addresses = LinkingObjects(fromType: Shipping.self, property: "user")
    
    convenience required init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        email = ("email" <~~ json)!
        name = ("name" <~~ json)!
        
        stripe_id = "stripe_id" <~~ json
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
