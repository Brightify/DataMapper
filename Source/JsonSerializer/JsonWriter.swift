//
//  JsonWriter.swift
//  DataMapper
//
//  Created by Filip Dolnik on 05.03.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

internal struct JsonWriter {
    
    private static let knownCharacters =
        ["\\u0000", "\\u0001", "\\u0002", "\\u0003", "\\u0004", "\\u0005", "\\u0006", "\\u0007", "\\b", "\\t", "\\n", "\\u000b", "\\f", "\\r", "\\u000e", "\\u000f", "\\u0010", "\\u0011", "\\u0012", "\\u0013", "\\u0014", "\\u0015", "\\u0016", "\\u0017", "\\u0018", "\\u0019", "\\u001a", "\\u001b", "\\u001c", "\\u001d", "\\u001e", "\\u001f", " ", "!", "\\\"", "#", "$", "%", "&", "\'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\\\", "]", "^", "_", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "\\u007f", "\\u0080", "\\u0081", "\\u0082", "\\u0083", "\\u0084", "\\u0085", "\\u0086", "\\u0087", "\\u0088", "\\u0089", "\\u008a", "\\u008b", "\\u008c", "\\u008d", "\\u008e", "\\u008f", "\\u0090", "\\u0091", "\\u0092", "\\u0093", "\\u0094", "\\u0095", "\\u0096", "\\u0097", "\\u0098", "\\u0099", "\\u009a", "\\u009b", "\\u009c", "\\u009d", "\\u009e", "\\u009f", "\\u00a0"]
    
    internal private(set) var result = String()

    internal mutating func serialize(supportedType: SupportedType) {
        // Null is not supported as a top-level JSON type
        guard supportedType.type != .null else { return }
        serializeRecursive(supportedType: supportedType)
    }

    private mutating func serializeRecursive(supportedType: SupportedType) {
        switch supportedType.type {
        case .string:
            serialize(string: supportedType.raw as! String)
        case .int, .intOrDouble:
            serialize(int: supportedType.raw as! Int)
        case .dictionary:
            serialize(dictionary: supportedType.raw as! [String: SupportedType])
        case .array:
            serialize(array: supportedType.raw as! [SupportedType])
        case .double:
            serialize(double: supportedType.raw as! Double)
        case .bool:
            serialize(bool: supportedType.raw as! Bool)
        default:
            serializeNull()
        }
    }
    
    private mutating func serialize(string: String) {
        result.append("\"")
        for character in string.unicodeScalars {
            if character.value <= 160 {
                result.append(JsonWriter.knownCharacters[Int(character.value)])
            } else {
                result.append(Character(character))
            }
        }
        result.append("\"")
    }
    
    private mutating func serialize(int: Int) {
        result.append(int.description)
    }
    
    private mutating func serialize(dictionary: [String: SupportedType]) {
        result.append("{")
        var first = true
        for (key, supportedType) in dictionary {
            if first {
                first = false
            } else {
                result.append(",")
            }
            serialize(string: key)
            result.append(":")
            serializeRecursive(supportedType: supportedType)
        }
        result.append("}")
    }

    private mutating func serialize(array: [SupportedType]) {
        result.append("[")
        var first = true
        for supportedType in array {
            if first {
                first = false
            } else {
                result.append(",")
            }
            serializeRecursive(supportedType: supportedType)
        }
        result.append("]")
    }
    
    private mutating func serialize(double: Double) {
        if double.isNaN || double.isInfinite {
            serializeNull()
        } else {
            result.append(double.description)
        }
    }
    
    private mutating func serialize(bool: Bool) {
        result.append(bool ? "true" : "false")
    }
    
    private mutating func serializeNull() {
        result.append("null")
    }
}
