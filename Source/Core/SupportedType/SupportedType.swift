//
//  SupportedType.swift
//  DataMapper
//
//  Created by Filip Dolnik on 20.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public final class SupportedType {
    
    public typealias Number = (bool: Bool?, int: Int?, double: Double?)

    public private(set) var raw: Any?
    
    public init(_ raw: Any?) {
        self.raw = raw
    }
    
    public func addToDictionary(key: String, value: SupportedType) {
        var mutableDictionary = dictionary ?? [:]
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
        return raw as? Bool ?? number?.bool
    }
    
    public var int: Int? {
        return raw as? Int ?? number?.int
    }
    
    public var double: Double? {
        return raw as? Double ?? number?.double
    }
    
    public var array: [SupportedType]? {
        return raw as? [SupportedType]
    }
    
    public var dictionary: [String: SupportedType]? {
        return raw as? [String: SupportedType]
    }
    
    public var number: Number? {
        return raw as? Number
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
}

extension SupportedType {
    
    public static func number(bool: Bool, int: Int) -> SupportedType {
        return SupportedType(Number(bool: bool, int: int, double: nil))
    }
    
    public static func number(bool: Bool, double: Double) -> SupportedType {
        return SupportedType(Number(bool: bool, int: nil, double: double))
    }
    
    public static func number(int: Int, double: Double) -> SupportedType {
        return SupportedType(Number(bool: nil, int: int, double: double))
    }
    
    public static func number(bool: Bool, int: Int, double: Double) -> SupportedType {
        return SupportedType(Number(bool: bool, int: int, double: double))
    }
}
