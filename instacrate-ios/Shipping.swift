//
//  Shipping.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Node
import RealmSwift

final class Shipping: Object, ObjectNodeInitializable {
    
    dynamic var id = 0

    dynamic var firstName = ""
    dynamic var lastName = ""
    
    dynamic var address = ""
    dynamic var apartment = ""
    
    dynamic var city = ""
    dynamic var state = ""
    dynamic var zip = ""

    dynamic var isDefault = false
    
    dynamic var customer: Customer? = nil

    var customer_id: Int?

    convenience required init(node: Node, in context: Context) throws {
        self.init()
        
        id = try node.extract("id")

        customer_id = try node.extract("customer_id")
        address = try node.extract("address")
        firstName = try node.extract("firstName")
        lastName = try node.extract("lastName")
        city = try node.extract("city")
        state = try node.extract("state")
        zip = try node.extract("zip")

        isDefault = (try? node.extract("isDefault")) ?? false
        apartment = (try? node.extract("apartment")) ?? ""
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func realmObject() -> Object {
        return self
    }
}
