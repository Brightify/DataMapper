//
//  SerializerTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 22.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class SerializerTest: QuickSpec {

    override func spec() {
        describe("Serializer extension") {
            let stub = SerializerStub()
            describe("serializeToString") {
                it("converts output of serialize to String(utf8)") {
                    expect(stub.serialize(toString: .string("abcd"))) == "abcd"
                }
            }
            describe("deserializeFromString") {
                it("returns deserialize with converted String(utf8) to Data") {
                    expect(stub.deserialize(fromString: "abcd")) == SupportedType.string("abcd")
                }
            }
        }
    }
    
    private struct SerializerStub: Serializer {
        
        func serialize(_ supportedType: SupportedType) -> Data {
            return supportedType.string?.data(using: .utf8) ?? Data()
        }
        
        func deserialize(_ data: Data) -> SupportedType {
            return .string(String(data: data, encoding: .utf8) ?? "")
        }
    }
}
