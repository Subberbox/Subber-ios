//
//  Boxes.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 11/1/16.
//  Copyright © 2016 Instacrate. All rights reserved.
//

import Foundation
import Moya

enum Format: String {

    case short
    case long

    public var responseType: ResponseType {
        switch self {
        case .short:
            return .object(Box.self)
        case .long:
            return .tuple(.object(Box.self),
                           ["pictures" : .array(.object(Picture.self)),
                            "reviews" : .array(.tuple(
                                .object(Review.self),
                                ["customer" : .object(Customer.self)])),
                            "vendor" : .object(Vendor.self)])
        }
    }
}

enum Curated: String {
    case all
    case featured
    case staffpicks
    case new
}

enum Boxes {

    case boxes(format: Format, curated: Curated)
    case box(format: Format, id: Int)
}

extension Boxes: ResponseTargetType {
    
    public var baseURL: URL {
        return URL(string: "http://api.instacrate.me/")!
    }
    
    public var path: String {

        switch self {
        case .boxes:
            return "boxes"
        case let .box(_, id):
            return "boxes/\(id)"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    var parameters: [String : Any]? {
        var parameters: [String : Any] = [:]

        if case let .boxes(_, curated) = self {
            parameters["curated"] = curated.rawValue
        }

        switch self {
        case let .boxes(format, _), let .box(format, _):
            parameters["format"] = format.rawValue
            return parameters
        }
    }
    
    public var task: Task {
        return .request
    }
    
    public var sampleData: Data {
        return "test".data(using: .utf8)!
    }
    
    public var responseType: ResponseType {
        switch self {
        case let .boxes(format, _):
            return .array(format.responseType)
        case let .box(format, _):
            return format.responseType
        }
    }
}
