//
//  ResponseParsing.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 11/1/16.
//  Copyright © 2016 Instacrate. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import Gloss
import Moya_Gloss

class BaseObject: Object, Decodable {
    
    convenience required init?(json: JSON) {
        fatalError("missing subclass implmementation")
    }
}

protocol ResponseTargetType: TargetType {
    
    var responseType: ResponseType { get }
}

indirect enum ResponseType {
    
    case object(BaseObject.Type)
    
    case array(ResponseType)
    case tuple([String : ResponseType])
}

extension Response {
    
    public func mapObject<T: Decodable>(_ type: T.Type, forKeyPath keyPath: String? = nil) throws -> T {
        if let key = keyPath, key != "" {
            return try mapObject(type, forKeyPath: key)
        } else {
            return try mapObject(type)
        }
    }
    
    public func mapArray<T: Decodable>(_ type: T.Type, forKeyPath keyPath: String? = nil) throws -> [T] {
        if let key = keyPath {
            return try mapArray(type, forKeyPath: key)
        } else {
            return try mapArray(type)
        }
    }
}

func collectResultsFrom(json: Any, forEndpoint endpoint: ResponseType) throws -> [Object] {
    
    var results: [Object] = []
    
    if case let .array(internalType) = endpoint {
        if let json = json as? [JSON] {
            try results.append(contentsOf: collectResultsFromArray(json: json, forEndpoint: internalType))
            return results
        }
    }
    
    switch endpoint {
    case let .object(type):
        guard let json = json as? JSON else { return [] }
        let object = type.init(json: json)
        return object != nil ? [object!] as [Object] : []

    case let .tuple(internals):
        guard let json = json as? JSON else { return [] }
        
        return try internals.flatMap { (tuple) -> [Object] in
            guard let value = json[tuple.key] else { return [] }
            return try collectResultsFrom(json: value, forEndpoint: tuple.value)
        }
        
    case .array(_):
        // Handled above
        break
    }
    
    return results
}

func collectResultsFromArray(json: [JSON], forEndpoint endpoint: ResponseType) throws -> [Object] {
    
    switch endpoint {
    case let .object(type):
        return json.flatMap { type.init(json: $0) } as [Object]
        
    case let .tuple(internalMapping):
        return try json.flatMap { tupleJSON in
            try internalMapping.flatMap { mapping in
                // Crash if mapping does not exist
                try collectResultsFrom(json: tupleJSON[mapping.key]!, forEndpoint: mapping.value)
            }
        }
        
    case .array:
        fatalError("Not allowed")
    }
}
