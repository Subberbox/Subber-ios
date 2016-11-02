//
//  Vendor.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Gloss
import RealmSwift

@objc
enum ApplicationState: Int {
    
    case none = 0
    case recieved
    case rejected
    case accepted
}

final class Vendor: BaseObject {
    
    dynamic var id: Int = 0

    dynamic var contactName = ""
    dynamic var contactPhone = ""
    dynamic var contactEmail = ""
    dynamic var applicationState: ApplicationState = .none
    
    dynamic var publicWebsite = ""
    dynamic var supportEmail = ""
    dynamic var businessName = ""
    
    dynamic var parentCompanyName = ""
    dynamic var established = ""
    
    dynamic var category: Category? = nil
    dynamic var estimatedTotalSubscribers = 0
    
    dynamic var dateCreated: Date = Date()

    dynamic var username = ""
    dynamic var password = ""
    
    dynamic var cut = 0.5
    
    let boxes = LinkingObjects(fromType: Box.self, property: "vendor")
    
    convenience required init?(json: JSON) {
        
        self.init()
        
        id = ("id" <~~ json)!
        
        applicationState = "applicationState" <~~ json ?? .none

        contactName = ("contactName" <~~ json)!
        businessName = ("businessName" <~~ json)!
        parentCompanyName = ("parentCompanyName" <~~ json)!
        
        contactPhone = ("contactPhone" <~~ json)!
        contactEmail = ("contactEmail" <~~ json)!
        supportEmail = ("supportEmail"  <~~ json)!
        publicWebsite = ("publicWebsite" <~~ json)!
        
        established = ("established" <~~ json)!
        dateCreated = Decoder.decode(dateISO8601ForKey: "dateCreated")(json)!
        
        estimatedTotalSubscribers = ("estimatedTotalSubscribers" <~~ json)!
        
        category = ("category" <~~ json)!
        cut = ("cut" <~~ json)!
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
