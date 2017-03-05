//
//  JsonSerializer.swift
//  DataMapper
//
//  Created by Filip Dolnik on 28.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public struct JsonSerializer: TypedSerializer {
    
    public typealias Json = Any
    
    public init() {
    }
    
    public func typedSerialize(_ supportedType: SupportedType) -> Json {
        return JsonSerializer.serializeToJson(supportedType)
    }
    
    public func serialize(_ supportedType: SupportedType) -> Data {
        let text: String?
        
        if let string = supportedType.string {
            text = "\"\(string)\""
        } else if let bool = supportedType.bool {
            text = "\(bool)"
        } else if let double = supportedType.double {
            text = "\(double)"
        } else if let int = supportedType.int {
            text = "\(int)"
        } else {
            text = nil
        }
        
        let data: Data?
        if let text = text {
            data = text.data(using: .utf8)
        } else if !supportedType.isNull {
            data = try? JSONSerialization.data(withJSONObject: typedSerialize(supportedType))
        } else {
            data = nil
        }
        
        return data ?? Data()
    }
    
    public func typedDeserialize(_ data: Json) -> SupportedType {
        return JsonSerializer.deserializeToSupportedType(data)
    }
    
    public func deserialize(_ data: Data) -> SupportedType {
        return typedDeserialize((try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) ?? NSNull())
    }

    private static func serializeToJson(_ supportedType: SupportedType) -> Json {
        if let number = supportedType.number {
            return number.bool ?? number.int ?? number.double ?? NSNull()
        } else if let array = supportedType.array {
            return array.map { serializeToJson($0) }
        } else if let dictionary = supportedType.dictionary {
            return dictionary.mapValue { serializeToJson($0) }
        } else {
            return supportedType.raw ?? NSNull()
        }
    }
 
    private static func deserializeToSupportedType(_ json: Json) -> SupportedType {
        switch json {
        case let number as NSNumber:
            let double = number.doubleValue
            if double == 1 || double == 0 {
                return .number(bool: number.boolValue, int: number.intValue, double: double)
            } else if double.truncatingRemainder(dividingBy: 1) == 0 {
                return .number(int: number.intValue, double: double)
            } else {
                return .double(double)
            }
        case let string as NSString:
            return .raw(string)
        case let array as NSArray:
            return .array(array.map { deserializeToSupportedType($0) })
        case let dictionary as NSDictionary:
            var mappedDictionary = [String: SupportedType](minimumCapacity: dictionary.count)
            for (key, value) in dictionary {
                if let key = key as? String {
                    mappedDictionary[key] = deserializeToSupportedType(value)
                } else {
                    return .null
                }
            }
            return .dictionary(mappedDictionary)
        default:
            return .null
        }
    }
}
