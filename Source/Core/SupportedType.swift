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

    public func appendToArray(value: SupportedType) {
        var mutableArray: [SupportedType]
        if let array = array {
            mutableArray = array
        } else {
            mutableArray = []
            type = .array
        }

        mutableArray.append(value)
        raw = mutableArray
    }
}

extension SupportedType {
    
    public var isNull: Bool {
        return raw == nil
    }

    public func setNull() {
        type = .null
        raw = nil
    }
    
    public var string: String? {
        get {
            return raw as? String
        }
        set {
            guard let newValue = newValue else {
                setNull()
                return
            }
            type = .string
            raw = newValue
        }
    }
    
    public var bool: Bool? {
        get {
            return raw as? Bool
        }
        set {
            guard let newValue = newValue else {
                setNull()
                return
            }
            type = .bool
            raw = newValue
        }
    }
    
    public var int: Int? {
        get {
            return raw as? Int
        }
        set {
            guard let newValue = newValue else {
                setNull()
                return
            }
            type = .int
            raw = newValue
        }
    }
    
    public var double: Double? {
        get {
            if type == .intOrDouble, let int = int {
                return Double(int)
            } else {
                return raw as? Double
            }
        }
        set {
            guard let newValue = newValue else {
                setNull()
                return
            }
            type = .double
            raw = newValue
        }

    }
    
    public var array: [SupportedType]? {
        get {
            return raw as? [SupportedType]
        }
        set {
            guard let newValue = newValue else {
                setNull()
                return
            }
            type = .array
            raw = newValue
        }
    }
    
    public var dictionary: [String: SupportedType]? {
        get {
            return raw as? [String: SupportedType]
        }
        set {
            guard let newValue = newValue else {
                setNull()
                return
            }
            type = .dictionary
            raw = newValue
        }
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
