//
//  JsonParser.swift
//  DataMapper
//
//  Created by Filip Dolnik on 07.03.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

internal final class JsonParser {
    
    private var data: String.UnicodeScalarView = "".unicodeScalars
    private var index: String.UnicodeScalarIndex
    private var hasNext: Bool = false
    
    internal init() {
        index = data.startIndex
    }
    
    internal func parse(data: Data) -> SupportedType {
        guard let scalars = String(data: data, encoding: .utf8)?.unicodeScalars else {
            error()
        }
        guard !scalars.isEmpty else {
            return .null
        }
        
        self.data = scalars
        index = self.data.startIndex
        hasNext = true
        
        let result = parseValue()
        while hasNext {
            if !next().isWhitespace {
                error()
            }
        }
        return result
    }
    
    private func parseValue() -> SupportedType {
        while hasNext {
            let character = next()
            if character.isWhitespace {
                continue
            }
            
            switch character {
            case "\"":
                return .string(parseString())
            case "{":
                return parseDictionary()
            case "[":
                return parseArray()
            case "t":
                return parseTrue()
            case "f":
                return parseFalse()
            case "n":
                return parseNull()
            default:
                repeatCharacter()
                return parseNumber()
            }
        }
        error()
    }
    
    private func parseString() -> String {
        var result = String.UnicodeScalarView()
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
                            error()
                        }
                    }
                    if let unicodeCharacter = UnicodeScalar(number) {
                        result.append(unicodeCharacter)
                    } else {
                        error()
                    }
                default:
                    error()
                }
            } else if character == "\"" {
                return String(result)
            } else if character == "\\" {
                escaped = true
            } else {
                result.append(character)
            }
        }
        error()
    }
    
    private enum DictionaryState {
        
        case start
        case key
        case colon
        case value
        case comma
    }
    
    private func parseDictionary() -> SupportedType {
        var result: [String: SupportedType] = [:]
        var nextKey = ""
        var state = DictionaryState.start
        
        while hasNext {
            let character = next()
            if character.isWhitespace {
                continue
            }
            
            switch state {
            case .start where character == "\"", .comma where character == "\"":
                nextKey = parseString()
                state = .key
            case .key where character == ":":
                state = .colon
            case .value where character == ",":
                state = .comma
            case .start where character == "}", .value where character == "}":
                return .dictionary(result)
            case .start, .key, .value, .comma:
                error()
            default:
                repeatCharacter()
                result[nextKey] = parseValue()
                state = .value
            }
        }
        error()
    }
    
    private enum ArrayState {
        
        case start
        case value
        case comma
    }
    
    private func parseArray() -> SupportedType {
        var result: [SupportedType] = []
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
                error()
            default:
                repeatCharacter()
                result.append(parseValue())
                state = .value
            }
        }
        error()
    }
    
    private func parseTrue() -> SupportedType {
        if next() == "r" && next() == "u" && next() == "e" {
            return .bool(true)
        } else {
            error()
        }
    }
    
    private func parseFalse() -> SupportedType {
        if next() == "a" && next() == "l" && next() == "s" && next() == "e" {
            return .bool(false)
        } else {
            error()
        }
    }
    
    private func parseNull() -> SupportedType {
        if next() == "u" && next() == "l" && hasNext && next() == "l" {
            return .bool(true)
        } else {
            error()
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
    
    private func parseNumber() -> SupportedType {
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
            error()
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
        index = data.index(before: index)
    }
    
    private func error() -> Never {
        fatalError("Invalid JSON. Index: \(index).")
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
