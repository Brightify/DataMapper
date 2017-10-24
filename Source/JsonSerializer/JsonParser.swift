//
//  JsonParser.swift
//  DataMapper
//
//  Created by Filip Dolnik on 07.03.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

internal enum JsonError: Error, CustomStringConvertible {
    case load(data: Data)
    case parse(index: String.UnicodeScalarIndex, line: Int, column: Int, character: UnicodeScalar, message: Message)

    var description: String {
        switch self {
        case .load:
            return "Couldn't load JSON."
        case .parse(_, let line, let column, _, let message):
            return "Couldn't parse JSON. \(message) at \(line):\(column)."
        }
    }

    var localizedDescription: String {
        return description
    }

    internal enum Message: CustomStringConvertible {
        case unexpectedEOF
        case onlyWhitespacesAtEnd
        case invalidUnicodeCharacter(UInt32)
        case unknownEscapedCharacter(UnicodeScalar)
        case unexpectedCharacter(UnicodeScalar, allowed: [UnicodeScalar])
        case invalidNumber

        var description: String {
            switch self {
            case .unexpectedEOF:
                return "Unexpected end of file"
            case .onlyWhitespacesAtEnd:
                return "Only whitespaces are allowed at the end of JSON file"
            case .invalidUnicodeCharacter(let number):
                return "Couldn't convert \(number) to a Unicode characted"
            case .unknownEscapedCharacter(let character):
                return "Unknown escaped character '\\\(character)'"
            case .unexpectedCharacter(let character, let allowedCharacters):
                let allowedCharactersJoined = allowedCharacters.map { String($0) }.joined(separator: ", ")
                return "Unexpected character \(character). Expected one of: \(allowedCharactersJoined)"
            case .invalidNumber:
                return "Couldn't parse number"
            }
        }
    }
}

internal final class JsonParser {
    
    private static let stringCapacity = 16
    private static let dictionaryCapacity = 8
    private static let arrayCapacity = 16
    
    private var data: String.UnicodeScalarView = "".unicodeScalars
    private var index: String.UnicodeScalarIndex
    private var hasNext: Bool = false
    
    internal init() {
        index = data.startIndex
    }

    internal func parse(data: Data) throws -> SupportedType {
        guard let scalars = String(data: data, encoding: .utf8)?.unicodeScalars else {
            throw JsonError.load(data: data)
        }
        guard !scalars.isEmpty else {
            return .null
        }
        
        self.data = scalars
        index = self.data.startIndex
        hasNext = true
        
        let result = try parseValue()
        while hasNext {
            let character = next()
            if !character.isWhitespace {
                throw createError(message: .onlyWhitespacesAtEnd)
            }
        }
        return result
    }
    
    private func parseValue() throws -> SupportedType {
        while hasNext {
            let character = next()
            if character.isWhitespace {
                continue
            }
            
            switch character {
            case "\"":
                return .string(try parseString())
            case "{":
                return try parseDictionary()
            case "[":
                return try parseArray()
            case "t":
                return try parseTrue()
            case "f":
                return try parseFalse()
            case "n":
                return try parseNull()
            default:
                repeatCharacter()
                return try parseNumber()
            }
        }
        throw createError(message: .unexpectedEOF)
    }
    
    private func parseString() throws -> String {
        var result = String.UnicodeScalarView()
        result.reserveCapacity(JsonParser.stringCapacity)
        var escaped = false
        
        while hasNext {
            let character = next()
            
            if escaped {
                escaped = false
                
                switch character {
                case "\"":
                    result.append("\"")
                case "\\":
                    result.append("\\")
                case "/":
                    result.append("/")
                case "b":
                    result.append("\u{8}")
                case "f":
                    result.append("\u{c}")
                case "n":
                    result.append("\n")
                case "r":
                    result.append("\r")
                case "t":
                    result.append("\t")
                case "u":
                    var number: UInt32 = 0
                    for _ in 0..<4 {
                        if hasNext {
                            number *= 16
                            let value = next()
                            if value.isDigit {
                                number += UInt32(value.asDigit())
                            } else if value >= "A" && value <= "F" {
                                number += value - "A" + 10
                            } else if value >= "a" && value <= "f" {
                                number += value - "a" + 10
                            }
                        } else {
                            throw createError(message: .unexpectedEOF)
                        }
                    }
                    if let unicodeCharacter = UnicodeScalar(number) {
                        result.append(unicodeCharacter)
                    } else {
                        throw createError(message: .invalidUnicodeCharacter(number))
                    }
                default:
                    throw createError(message: .unknownEscapedCharacter(character))
                }
            } else if character == "\"" {
                return String(result)
            } else if character == "\\" {
                escaped = true
            } else {
                result.append(character)
            }
        }
        throw createError(message: .unexpectedEOF)
    }
    
    private enum DictionaryState {
        
        case start
        case key
        case colon
        case value
        case comma
    }
    
    private func parseDictionary() throws -> SupportedType {
        var result = Dictionary<String, SupportedType>(minimumCapacity: JsonParser.dictionaryCapacity)
        var nextKey = ""
        var state = DictionaryState.start
        
        while hasNext {
            let character = next()
            if character.isWhitespace {
                continue
            }
            
            switch state {
            case .start where character == "\"", .comma where character == "\"":
                nextKey = try parseString()
                state = .key
            case .key where character == ":":
                state = .colon
            case .value where character == ",":
                state = .comma
            case .start where character == "}", .value where character == "}":
                return .dictionary(result)
            case .start, .key, .value, .comma:
                throw createError(message: .unexpectedCharacter(character, allowed: ["\"", ":", ",", "}"]))

            default:
                repeatCharacter()
                result[nextKey] = try parseValue()
                state = .value
            }
        }
        throw createError(message: .unexpectedEOF)
    }
    
    private enum ArrayState {
        
        case start
        case value
        case comma
    }
    
    private func parseArray() throws -> SupportedType {
        var result: [SupportedType] = []
        result.reserveCapacity(JsonParser.arrayCapacity)
        var state = ArrayState.start
        
        while hasNext {
            let character = next()
            if character.isWhitespace {
                continue
            }
            
            switch state {
            case .value where character == ",":
                state = .comma
            case .start where character == "]", .value where character == "]":
                return .array(result)
            case .value:
                throw createError(message: .unexpectedCharacter(character, allowed: [",", "]"]))
            default:
                repeatCharacter()
                result.append(try parseValue())
                state = .value
            }
        }
        throw createError(message: .unexpectedEOF)
    }

    private func parseTrue() throws -> SupportedType {
        try ensureExpectedCharacter("r")
        try ensureExpectedCharacter("u")
        try ensureExpectedCharacter("e")

        return .bool(true)
    }
    
    private func parseFalse() throws -> SupportedType {
        try ensureExpectedCharacter("a")
        try ensureExpectedCharacter("l")
        try ensureExpectedCharacter("s")
        try ensureExpectedCharacter("e")

        return .bool(false)
    }
    
    private func parseNull() throws -> SupportedType {
        try ensureExpectedCharacter("u")
        try ensureExpectedCharacter("l")
        try ensureExpectedCharacter("l")

        return .null
    }
    
    private func ensureExpectedCharacter(_ expected: UnicodeScalar) throws {
        let character = next()
        guard character == expected else {
            throw createError(message: .unexpectedCharacter(character, allowed: [expected]))
        }
    }

    private enum NumberState {
        
        case start
        case leadingZero
        case int
        case dot
        case double
        case e
        case eSign
        case exponent
    }
    
    private func parseNumber() throws -> SupportedType {
        var negative = false
        var negativeExponent = false
        var exponent: Double = 0
        var mantisa: Double = 0
        var subtractFromExponent = 0
        var state = NumberState.start
        
        loop: while hasNext {
            let character = next()
            
            switch state {
            case .start where character == "-" && !negative:
                negative = true
            case .start where character == "0":
                state = .leadingZero
            case .start where character.isDigit:
                state = .int
                fallthrough
            case .int where character.isDigit:
                mantisa *= 10
                mantisa += Double(character.asDigit())
            case .leadingZero where character == ".", .int where character == ".":
                state = .dot
            case .dot where character.isDigit:
                state = .double
                fallthrough
            case .double where character.isDigit:
                mantisa *= 10
                mantisa += Double(character.asDigit())
                subtractFromExponent += 1
            case .leadingZero where character.isE, .int where character.isE, .double where character.isE:
                state = .e
            case .e where character == "-":
                negativeExponent = true
                fallthrough
            case .e where character == "+":
                state = .eSign
            case .e where character.isDigit, .eSign where character.isDigit:
                state = .exponent
                fallthrough
            case .exponent where character.isDigit:
                exponent *= 10
                exponent += Double(character.asDigit())
            default:
                repeatCharacter()
                break loop
            }
        }
        
        switch state {
        case .start, .dot, .e, .eSign:
            throw createError(message: .invalidNumber)

        default:
            if negative {
                mantisa *= -1
            }
            if negativeExponent {
                exponent *= -1
            }
            let number = Double(mantisa) * pow(10, exponent - Double(subtractFromExponent))
            let integer = Int(number)
            return Double(integer) == number ? .intOrDouble(integer) : .double(number)
        }
    }
    
    private func next() -> UnicodeScalar {
        let character = data[index]
        let newIndex = data.index(after: index)
        if newIndex == data.endIndex {
            hasNext = false
        } else {
            index = newIndex
        }
        return character
    }
    
    private func repeatCharacter() {
        if hasNext {
            index = data.index(before: index)
        } else {
            hasNext = true
        }
    }
    
    private func createError(message: JsonError.Message) -> JsonError {
        let character = data[index]

        var line = 1
        var column = data.distance(from: data.startIndex, to: index)
        for c in data[..<index] {
            if c == "\n" {
                line += 1
            }
            column -= 1
        }

        return JsonError.parse(index: index, line: line, column: column, character: character, message: message)
    }
}

private extension UnicodeScalar {
    
    var isWhitespace: Bool {
        switch value {
        case 32, 9, 10, 13: // Space, Horizontal tab, Line feed or New line, Carriage return
            return true
        default:
            return false
        }
    }
    
    var isDigit: Bool {
        return self >= "0" && self <= "9"
    }
    
    var isE: Bool {
        return self == "e" || self == "E"
    }
    
    func asDigit() -> Int {
        return Int(self - "0")
    }
}

private func -(lhs: UnicodeScalar, rhs: UnicodeScalar) -> UInt32 {
    return lhs.value - rhs.value
}
