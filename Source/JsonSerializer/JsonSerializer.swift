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
        switch supportedType.type {
        case .dictionary:
            return (supportedType.raw as! [String: SupportedType]).mapValues { typedSerialize($0) }
        case .array:
            return (supportedType.raw as! [SupportedType]).map { typedSerialize($0) }
        default:
            return supportedType.raw ?? NSNull()
        }
    }
 
    public func serialize(_ supportedType: SupportedType) -> Data {
        var writer = JsonWriter()
        writer.serialize(supportedType: supportedType)
        return writer.result.data(using: .utf8) ?? Data()
    }

    public func typedDeserialize(_ data: Json) -> SupportedType {
        switch data {
        case let string as String:
            return .string(string)
        case let dictionary as [String: Any]:
            return .dictionary(dictionary.mapValues { typedDeserialize($0) })
        case let array as [Any]:
            return .array(array.map { typedDeserialize($0) })
        default:
            if let int = data as? Int, let double = data as? Double {
                if Double(int) != double {
                    return .double(double)
                } else {
                    return .intOrDouble(int)
                }
            } else if let int = data as? Int {
                return .int(int)
            } else if let double = data as? Double {
                return .double(double)
            } else if let bool = data as? Bool {
                return .bool(bool)
            } else {
                return .null
            }
        }
    }
    
    public func deserialize(_ data: Data) -> SupportedType {
        return JsonParser().parse(data: data)
    }
}
