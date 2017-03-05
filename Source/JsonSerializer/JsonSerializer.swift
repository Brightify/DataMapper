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
        if let dictionary = supportedType.dictionary {
            var mappedDictionary = [String: Json](minimumCapacity: dictionary.count)
            for (key, supportedType) in dictionary {
                mappedDictionary[key] = typedSerialize(supportedType)
            }
            return mappedDictionary
        } else if let array = supportedType.array {
            var mappedArray: [Json] = []
            mappedArray.reserveCapacity(array.count)
            for supportedType in array {
                mappedArray.append(typedSerialize(supportedType))
            }
            return mappedArray
        } else {
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
            var mappedDictionary = [String: SupportedType](minimumCapacity: dictionary.count)
            for (key, value) in dictionary {
                mappedDictionary[key] = typedDeserialize(value)
            }
            return .dictionary(mappedDictionary)
        case let array as [Any]:
            var mappedArray: [SupportedType] = []
            mappedArray.reserveCapacity(array.count)
            for value in array {
                mappedArray.append(typedDeserialize(value))
            }
            return .array(mappedArray)
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
        return typedDeserialize((try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) ?? NSNull())
    }
}
