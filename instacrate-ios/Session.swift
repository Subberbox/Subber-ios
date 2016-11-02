//
//  UserSession.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/28/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class Session: BaseObject {
    
    dynamic var id = 0
    dynamic var exists = false
    
    dynamic var accessToken = ""
    
    dynamic var user: User? = nil
    
    convenience required init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        accessToken = ("accessToken" <~~ json)!
        user = ("user" <~~ json)!
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
