//
//  Vendor.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import RealmSwift
import Node

@objc
enum ApplicationState: Int {
    
    case none = 0
    case recieved
    case rejected
    case accepted

    init(from string: String) throws {
        switch string {
        case "none":
            self = .none
            return
        case "recieved":
            self = .recieved
        case "rejected":
            self = .rejected
        case "accepted":
            self = .accepted
            return
        default:
            throw GenericError()
        }
    }
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

    dynamic var username = ""
    
    dynamic var category: Category? = nil
    dynamic var estimatedTotalSubscribers = 0
//    var verificationState: LegalEntityVerificationStatus?

    dynamic var dateCreated: Date = Date()
    
    dynamic var cut = 0.5

    var stripeAccountId: String?
    
    let boxes = LinkingObjects(fromType: Box.self, property: "vendor")

    var category_id: Int?

    convenience required init(node: Node, in context: Context) throws {
        self.init()

        id = try node.extract("id")

        applicationState = (try? node.extract("applicationState") { (freq: String) in
            return try ApplicationState.init(from: freq)
        }) ?? .none

        username = try node.extract("username")

        contactName = try node.extract("contactName")
        businessName = try node.extract("businessName")
        parentCompanyName = try node.extract("parentCompanyName")

        contactPhone = try node.extract("contactPhone")
        contactEmail = try node.extract("contactEmail")
        supportEmail = try node.extract("supportEmail")
        publicWebsite = try node.extract("publicWebsite")

        established = try node.extract("established")

        dateCreated = (try? node.extract("dateCreated") { (dateString: String) in
            try Date(ISO8601String: dateString)
        }) ?? Date()

        estimatedTotalSubscribers = try node.extract("estimatedTotalSubscribers")

        category_id = try node.extract("category_id")

        cut = (try? node.extract("cut")) ?? 0.08
        stripeAccountId = try? node.extract("stripeAccountId")
//        verificationState = try? node.extract("verificationState")
    }

    override func link(with objects: [BaseObject]) {

        if let category_id = category_id {
            category = objects.find(primaryKey: category_id)
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
