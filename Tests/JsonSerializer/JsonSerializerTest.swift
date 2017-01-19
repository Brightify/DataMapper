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
            let type = TestData.generateType(x: 3)
                
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
}
