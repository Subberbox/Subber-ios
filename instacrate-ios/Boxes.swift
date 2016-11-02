//
//  Boxes.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 11/1/16.
//  Copyright © 2016 Instacrate. All rights reserved.
//

import Foundation
import Moya

enum Boxes {
    
    case all
    case featured
    case new
    case boxes(category: Int)
    
    case box(id: Int)
    case list(ids: [Int])
}

extension Boxes: ResponseTargetType {
    
    public var baseURL: URL {
        return URL(string: "http://api.instacrate.me/")!
    }
    
    public var path: String {
        switch self {
        case .all: return "box/all"
        case .featured: return "box/featured"
        case .new: return "box/new"
            
        case .box(let id): return "box/\(id)"
            
        case .boxes(let category): return "box/category/\(category)"
        case .list(_): return "box/"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .list(let ids): return ["id" : ids]
        default: return nil
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
        case .all: fallthrough
        case .featured: fallthrough
        case .new: fallthrough
        case .boxes(_): fallthrough
        case .list(_):
            return .array(.tuple(["box" : .object(Box.self),
                                  "pictures" : .array(.object(Picture.self)),
                                  "reviews" : .array(.object(Review.self))]))
            
        case .box(_): return .tuple(["box" : .object(Box.self),
                                     "pictures" : .array(.object(Picture.self)),
                                     "reviews" : .array(.object(Review.self))])
        }
    }
}
