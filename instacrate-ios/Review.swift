//
//  Review.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Gloss
import RealmSwift

final class Review: BaseObject {
    
    dynamic var id = 0
    
    dynamic var text = ""
    dynamic var rating = 0
    dynamic var date = Date()
    
    dynamic var box: Box? = nil
    dynamic var user: User? = nil
    
    convenience required init?(json: JSON) {
        self.init()
        
        id = ("id" <~~ json)!
        text = ("text" <~~ json)!
        rating = ("rating" <~~ json)!
        
        if let interval: Double = "date" <~~ json {
            self.date = Date(timeIntervalSince1970: interval)
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
