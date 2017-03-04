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
        return JsonSerializer.serializeToAny(supportedType)
    }
    
    public func serialize(_ supportedType: SupportedType) -> Data {
        let data: Data?
        switch supportedType {
        case .null:
            data = nil
        case .string(let value):
            data = "\"\(value)\"".data(using: .utf8)
        case .number(let value):
            data = JsonSerializer.numberToString(value).data(using: .utf8)
        default:
            data = try? JSONSerialization.data(withJSONObject: typedSerialize(supportedType))
        }
        return data ?? Data()
    }
    
    public func typedDeserialize(_ data: Any) -> SupportedType {
        return JsonSerializer.deserializeToSupportedType(data)
    }
    
    public func deserialize(_ data: Data) -> SupportedType {
        return typedDeserialize((try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) ?? NSNull())
    }
    
    private static func serializeToAny(_ supportedType: SupportedType) -> Any {
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
    
    private static func deserializeToSupportedType(_ json: Any) -> SupportedType {
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
    
    private static func numberToString(_ number: SupportedNumber) -> String {
        if let bool = number.bool {
            return "\(bool)"
        } else if let double = number.double {
            return "\(double)"
        } else if let int = number.int {
            return "\(int)"
        } else {
            return ""
        }
    }
}
