//
//  Boxes.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 11/1/16.
//  Copyright © 2016 Instacrate. All rights reserved.
//

import Foundation
import Moya

enum Format {

    case short
    case long
}

enum Boxes {
    
    case all(format: Format)
    case featured(format: Format)
    case new(format: Format)

    case box(format: Format, id: Int)
}

extension Boxes: ResponseTargetType {
    
    public var baseURL: URL {
        return URL(string: "http://api.instacrate.me/")!
    }
    
    public var path: String {
        return "box"
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    public var task: Task {
        return .request
    }
    
    public var sampleData: Data {
        return "test".data(using: .utf8)!
    }

    private var baseResponseType: ResponseType {
        switch self {
        case let .all(format), let .featured(format), let .new(format), let .box(format, _):
            switch format {
            case .short:
                return .object(Box.self)
            case .long:
                return .tuple(["box" : .object(Box.self),
                               "pictures" : .array(.object(Picture.self)),
                               "reviews" : .array(.object(Review.self))])
            }
        }
    }
    
    public var responseType: ResponseType {
        if case .box = self {
            return self.baseResponseType
        } else {
            return .array(self.baseResponseType)
        }
    }
}
