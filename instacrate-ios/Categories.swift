//
//  Categories.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/7/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import Moya

enum Categories {
    
    case categories
}

extension Categories: ResponseTargetType {
    
    var baseURL: URL {
        return URL(string: "http://api.instacrate.me/")!
    }
    
    var path: String {
        switch self {
        case .categories:
            return "categories"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var task: Task {
        return .request
    }
    
    var sampleData: Data {
        return "test".data(using: .utf8)!
    }
    
    var responseType: ResponseType {
        switch self {
        case .categories:
            return .array(.object(Category.self))
        }
    }
    
    var string: String {
        return "<Endpoint: categories>"
    }
}
