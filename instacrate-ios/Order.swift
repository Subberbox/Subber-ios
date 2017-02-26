//
//  Order.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Node
import RealmSwift

final class Order: Object, ObjectNodeInitializable {
    
    dynamic var id = 0
    
    dynamic var date = Date()
    dynamic var fulfilled = false
    
    dynamic var subscription: Subscription? = nil
    dynamic var address: Shipping? = nil
    dynamic var vendor: Vendor? = nil

    var subscription_id: Int?
    var shipping_id: Int?
    var vendor_id: Int?

    convenience required init(node: Node, in context: Context) throws {
        self.init()
        
        id = try node.extract("id")

        date = (try? node.extract("date") { (stringValue: String) in
            try Date(ISO8601String: stringValue)
        }) ?? Date()

        fulfilled = (try? node.extract("fulfilled")) ?? false

        subscription_id = try node.extract("subscription_id")
        shipping_id = try node.extract("shipping_id")
        vendor_id = try node.extract("vendor_id")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id" : .number(.int(id)),
            "date" : .string(date.ISO8601String),
            "fulfilled" : .bool(fulfilled),
            "subscription_id" : .number(.int(subscription_id!)),
            "shipping_id" : .number(.int(shipping_id!)),
            "vendor_id" : .number(.int(vendor_id!))
        ])
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func realmObject() -> Object {
        return self
    }
}
