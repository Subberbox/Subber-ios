//
//  Shippings.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/26/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import Stripe
import Moya

enum Shippings {
    
    case create(address: STPAddress)
}

extension Shippings: ResponseTargetType {
    
    var baseURL: URL {
        return URL(string: "http://api.instacrate.me/")!
    }
    
    var path: String {
        switch self {
        case .create:
            return "shipping"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .create:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .create(address):
            return ["address" : address.line1 ?? "",
                    "firstName" : address.name ?? "",
                    "lastName" : "lastName",
                    "city" : address.city ?? "",
                    "state" : address.state ?? "",
                    "zip" : address.postalCode ?? ""]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var task: Task {
        return .request
    }
    
    var sampleData: Data {
        return "test".data(using: .utf8)!
    }
    
    var responseType: ResponseType {
        switch self {
        case .create:
            return .object(Shipping.self)
        }
    }
    
    var string: String {
        return "<Endpoint: shipping>"
    }
}
