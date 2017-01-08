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
import Node
import Jay

extension JSON {

    func toNode() -> Node {
        switch self {
        case .array(let values):
            return .array(values.map { $0.toNode() })
        case .boolean(let value):
            return .bool(value)
        case .null:
            return .null
        case .number(let number):
            let num: Node.Number
            switch number {
            case .double(let value):
                num = .double(value)
            case .integer(let value):
                num = .int(value)
            case .unsignedInteger(let value):
                num = .uint(value)
            }
            return .number(num)
        case .object(let values):
            var dictionary: [String: Node] = [:]
            for (key, value) in values {
                dictionary[key] = value.toNode()
            }
            return .object(dictionary)
        case .string(let value):
            return .string(value)
        }
    }
}

internal extension Date {

    init(ISO8601String: String) throws {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        guard let date = dateFormatter.date(from: ISO8601String) else {
            throw GenericError()
        }

        self = date
    }

    var ISO8601String: String {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        return dateFormatter.string(from: self)
    }
}


internal extension Node {

    func add(name: String, node: Node?) throws -> Node {
        if let node = node {
            return try add(name: name, node: node)
        }

        return self
    }

    func add(name: String, node: Node) throws -> Node {
        guard var object = self.nodeObject else { throw NodeError.unableToConvert(node: self, expected: "[String: Node].self") }
        object[name] = node
        return try Node(node: object)
    }

    func add(objects: [String : NodeConvertible?]) throws -> Node {
        guard var nodeObject = self.nodeObject else { throw NodeError.unableToConvert(node: self, expected: "[String: Node].self") }

        for (name, object) in objects {
            if let node = try object?.makeNode() {
                nodeObject[name] = node
            }
        }

        return try Node(node: nodeObject)
    }
}

protocol Linkable {

    func link() throws
}

class BaseObject: Object, NodeConvertible, Linkable {

    required convenience init(node: Node, in context: Context = EmptyNode) throws {
        self.init()
    }

    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [])
    }

    func link() throws {
        
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

func parse(json: JSON, from endpoint: ResponseTargetType) throws -> [BaseObject] {
    return try parse(node: json.toNode(), from: endpoint.responseType)
}

func parse(node: Node, from endpoint: ResponseType) throws -> [BaseObject] {
    
    var results: [BaseObject] = []
    
    switch endpoint {
    case let .object(type):
        try results.append(type.init(node: node))

    case let .tuple(internals):
        try results.append(contentsOf: internals.flatMap { (tuple) -> [BaseObject] in
            guard let subnode = node[tuple.key] else { throw GenericError() }
            return try parse(node: subnode, from: tuple.value)
        })
        
    case let .array(type):
        guard case let .array(subnodes) = node else {
            throw GenericError()
        }

        try results.append(contentsOf: subnodes.flatMap { subnode -> [BaseObject] in
            return try parse(node: subnode, from: type)
        })
    }
    
    return results
}
