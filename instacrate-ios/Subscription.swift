//
//  Subscription.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Node
import RealmSwift

struct GenericError: Error {

}

@objc
enum Frequency: Int {

    case once
    case monthly

    init(from string: String) throws {
        switch string {
        case "once":
            self = .once
            return
        case "monthly":
            self = .monthly
            return
        default:
            throw GenericError()
        }
    }
}

final class Subscription: BaseObject {
    
    dynamic var id = 0

    dynamic var date = Date()
    dynamic var active = true
    dynamic var frequency: Frequency = .monthly

    dynamic var box: Box? = nil
    dynamic var address: Shipping? = nil
    dynamic var customer: Customer? = nil

    dynamic var sub_id: String = ""

    var box_id: Int?
    var shipping_id: Int?
    var customer_id: Int?

    let orders = LinkingObjects(fromType: Order.self, property: "subscription")

    convenience required init(node: Node, in context: Context) throws {
        self.init()

        id = try node.extract("id")

        date = (try? node.extract("date") { (dateString: String) in
            try Date(ISO8601String: dateString)
        }) ?? Date()

        active = (try? node.extract("active")) ?? true

        frequency = (try? node.extract("frequency") { (freq: String) in
            return try Frequency.init(from: freq)
        }) ?? .monthly

        box_id = try node.extract("box_id")
        shipping_id = try node.extract("shipping_id")
        customer_id = try node.extract("customer_id")

        sub_id = (try? node.extract("sub_id")) ?? ""
    }

    override func link() throws {
        if let box_id = box_id {
            box = try Realm().object(ofType: Box.self, forPrimaryKey: box_id)
        }

        if let shipping_id = shipping_id {
            address = try Realm().object(ofType: Shipping.self, forPrimaryKey: shipping_id)
        }

        if let customer_id = customer_id {
            customer = try Realm().object(ofType: Customer.self, forPrimaryKey: customer_id)
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
