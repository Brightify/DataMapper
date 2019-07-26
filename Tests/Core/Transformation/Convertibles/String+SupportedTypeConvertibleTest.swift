//
//  String+SupportedTypeConvertibleTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 31.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class String_SupportedTypeConvertibleTest: QuickSpec {
    
    override func spec() {
        describe("String") {
            it("can be used in ObjectMapper without transformation") {
                let objectMapper = ObjectMapper()
                let value = "a"
                let type: SupportedType = .string("a")
                
                expect(try? objectMapper.deserialize(String.self, from: type)) == value
                expect(objectMapper.serialize(value)) == type
            }
        }
    }
}
