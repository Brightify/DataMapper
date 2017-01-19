//
//  JsonSerializer.swift
//  DataMapper
//
//  Created by Filip Dolnik on 28.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public struct JsonSerializer: TypedSerializer {
    
    public init() {
    }
    
    public func typedSerialize(_ supportedType: SupportedType) -> Any {
        return serializeToAny(supportedType)
    }
    
    public func serialize(_ supportedType: SupportedType) -> Data {
        return (try? JSONSerialization.data(withJSONObject: typedSerialize(supportedType))) ?? Data()
    }
    
    public func typedDeserialize(_ data: Any) -> SupportedType {
        return deserializeToSupportedType(data)
    }
    
    public func deserialize(_ data: Data) -> SupportedType {
        return typedDeserialize((try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) ?? NSNull())
    }
    
    private func serializeToAny(_ supportedType: SupportedType) -> Any {
        switch supportedType {
        case .null:
            return NSNull()
        case .string(let string):
            return string
        case .number(let number):
            return number.bool ?? number.double ?? number.int as Any
        case .array(let array):
            return array.map { serializeToAny($0) }
        case .dictionary(let dictionary):
            return dictionary.mapValue { serializeToAny($0) }
        }
    }
    
    private func deserializeToSupportedType(_ json: Any) -> SupportedType {
        switch json {
        case let number as NSNumber:
            let double = number.doubleValue
            if double == 1 || double == 0 {
                return .number(SupportedNumber(bool: number.boolValue, int: number.intValue, double: double))
            } else if double.truncatingRemainder(dividingBy: 1) == 0 {
                return .number(SupportedNumber(int: number.intValue, double: double))
            } else {
                return .double(double)
            }
        case let string as String:
            return .string(string)
        case let array as [Any]:
            return .array(array.map { deserializeToSupportedType($0) })
        case let dictionary as [String: Any]:
            return .dictionary(dictionary.mapValue { deserializeToSupportedType($0) })
        default:
            return .null
        }
    }
}
