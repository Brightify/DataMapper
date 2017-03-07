//
//  SupportedType.swift
//  DataMapper
//
//  Created by Filip Dolnik on 20.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public final class SupportedType: CustomStringConvertible {
    
    public enum RawType {
        
        case null
        case string
        case bool
        case int
        case double
        case array
        case dictionary
        case intOrDouble
    }
    
    public private(set) var raw: Any?
    public private(set) var type: RawType
    
    public var description: String {
        return String(describing: raw)
    }
    
    public init(raw: Any?, type: RawType) {
        self.raw = raw
        self.type = type
    }
    
    public func addToDictionary(key: String, value: SupportedType) {
        var mutableDictionary: [String: SupportedType]
        if let dictionary = dictionary {
            mutableDictionary = dictionary
        } else {
            mutableDictionary = [:]
            type = .dictionary
        }
        mutableDictionary[key] = value
        raw = mutableDictionary
    }
}

extension SupportedType {
    
    public var isNull: Bool {
        return raw == nil
    }
    
    public var string: String? {
        return raw as? String
    }
    
    public var bool: Bool? {
        return raw as? Bool
    }
    
    public var int: Int? {
        return raw as? Int
    }
    
    public var double: Double? {
        if type == .intOrDouble, let int = int {
            return Double(int)
        } else {
            return raw as? Double
        }
    }
    
    public var array: [SupportedType]? {
        return raw as? [SupportedType]
    }
    
    public var dictionary: [String: SupportedType]? {
        return raw as? [String: SupportedType]
    }
}

extension SupportedType {
    
    public static func raw(_ raw: Any?, type: RawType) -> SupportedType {
        return SupportedType(raw: raw, type: type)
    }
    
    public static var null: SupportedType {
        return SupportedType(raw: nil, type: .null)
    }

    public static func string(_ value: String) -> SupportedType {
        return SupportedType(raw: value, type: .string)
    }
    
    public static func bool(_ value: Bool) -> SupportedType {
        return SupportedType(raw: value, type: .bool)
    }
    
    public static func int(_ value: Int) -> SupportedType {
        return SupportedType(raw: value, type: .int)
    }
    
    public static func double(_ value: Double) -> SupportedType {
        return SupportedType(raw: value, type: .double)
    }
    
    public static func array(_ value: [SupportedType]) -> SupportedType {
        return SupportedType(raw: value, type: .array)
    }
    
    public static func dictionary(_ value: [String: SupportedType]) -> SupportedType {
        return SupportedType(raw: value, type: .dictionary)
    }
    
    public static func intOrDouble(_ value: Int) -> SupportedType {
        return SupportedType(raw: value, type: .intOrDouble)
    }
}
