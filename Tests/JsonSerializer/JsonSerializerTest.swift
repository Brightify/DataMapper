//
//  JsonSerializerTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 19.01.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class JsonSerializerTest: QuickSpec {
    
    override func spec() {
        describe("JsonSerializer") {
            let serializer = JsonSerializer()
            let type: SupportedType = .dictionary([
                    "int": number(2),
                    "double": .double(1.1),
                    "bool": number(1),
                    "text": .string("A"),
                    "null": .null,
                    "array": .array([number(0), number(1), number(2), .null]),
                    "dictionary": .dictionary(["null": .null, "text": .string("B")])
                ])
            
            describe("serialize") {
                it("returns empty data is input is .null") {
                    let data = serializer.serialize(.null)
                    
                    expect(String(data: data, encoding: .utf8)) == ""
                }
            }
            describe("typed serialize and deserialize") {
                it("serializes and deserializes to the same type") {
                    let json = serializer.typedSerialize(type)
                    
                    let result = serializer.typedDeserialize(json)
                    
                    expect(result) == type
                }
            }
            describe("serialize and deserialize") {
                it("serializes and deserializes to the same type") {
                    let data = serializer.serialize(type)
                    
                    let result = serializer.deserialize(data)
                    
                    expect(result) == type
                }
            }
        }
    }
    
    private func number(_ value: Int) -> SupportedType {
        return .number(value == 0 || value == 1 ? SupportedNumber(bool: value == 1, int: value, double: Double(value)) :
            SupportedNumber(int: value, double: Double(value)))
    }
}
