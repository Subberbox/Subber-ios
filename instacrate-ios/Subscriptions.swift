//
//  Subscriptions.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/26/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import Moya

enum Period: String {
    
    case once
    case monthly
}

enum Subscriptions {
    
    case create(box_id: Int, frequency: Period, shipping_id: Int, source: String, couponCode: String?)
}

extension Subscriptions: ResponseTargetType {
    
    var baseURL: URL {
        return URL(string: "http://api.instacrate.me/")!
    }
    
    var path: String {
        switch self {
        case .create:
            return "subscriptions"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .create(box_id, period, shipping_id, source, couponCode):
            var parameters = ["box_id" : box_id, "frequency" : period.rawValue, "shipping_id" : shipping_id, "source" : source] as [String: Any]
            
            if let couponCode = couponCode {
                parameters["couponCode"] = couponCode
            }
            
            return parameters
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
            return .object(Subscription.self)
        }
    }
    
    var string: String {
        return "<Endpoint: subscriptions>"
    }
}
