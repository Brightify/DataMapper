//
//  SupportedType.swift
//  DataMapper
//
//  Created by Filip Dolnik on 20.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public final class SupportedType: CustomStringConvertible {
    
    public private(set) var raw: Any?
    
    fileprivate var isIntOrDouble = false
    
    public var description: String {
        return String(describing: raw)
    }
    
    public init(_ raw: Any?) {
        self.raw = raw
    }
    
    public func addToDictionary(key: String, value: SupportedType) {
        var mutableDictionary: [String: SupportedType]
        if let dictionary = dictionary {
            mutableDictionary = dictionary
        } else {
            mutableDictionary = [:]
            isIntOrDouble = false
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
        if isIntOrDouble, let int = int {
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
    
    public static func raw(_ raw: Any?) -> SupportedType {
        return SupportedType(raw)
    }
    
    public static var null: SupportedType {
        return SupportedType(nil)
    }

    public static func string(_ value: String) -> SupportedType {
        return SupportedType(value)
    }
    
    public static func bool(_ value: Bool) -> SupportedType {
        return SupportedType(value)
    }
    
    public static func int(_ value: Int) -> SupportedType {
        return SupportedType(value)
    }
    
    public static func double(_ value: Double) -> SupportedType {
        return SupportedType(value)
    }
    
    public static func array(_ value: [SupportedType]) -> SupportedType {
        return SupportedType(value)
    }
    
    public static func dictionary(_ value: [String: SupportedType]) -> SupportedType {
        return SupportedType(value)
    }
    
    public static func intOrDouble(_ value: Int) -> SupportedType {
        let type = SupportedType(value)
        type.isIntOrDouble = true
        return type
    }
}
