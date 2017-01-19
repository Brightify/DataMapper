//
//  SupportedType+SupportedNumber.swift
//  DataMapper
//
//  Created by Filip Dolnik on 30.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

extension SupportedType {
    
    public static func bool(_ value: Bool) -> SupportedType {
        return .number(SupportedNumber(bool: value))
    }
    
    public static func int(_ value: Int) -> SupportedType {
        return .number(SupportedNumber(int: value))
    }
    
    public static func double(_ value: Double) -> SupportedType {
        return .number(SupportedNumber(double: value))
    }
    
    public var bool: Bool? {
        return number?.bool
    }
    
    public var int: Int? {
        return number?.int
    }
    
    public var double: Double? {
        return number?.double
    }
}
