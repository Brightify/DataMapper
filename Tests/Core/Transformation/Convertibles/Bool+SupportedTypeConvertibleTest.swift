//
//  Bool+SupportedTypeConvertibleTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 31.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class Bool_SupportedTypeConvertibleTest: QuickSpec {
    
    override func spec() {
        describe("Bool") {
            it("can be used in ObjectMapper without transformation") {
                let objectMapper = ObjectMapper()
                let value = true
                let type: SupportedType = .bool(true)
                
                expect(try? objectMapper.deserialize(Bool.self, from: type)) == value
                expect(objectMapper.serialize(value)) == type
            }
        }
    }
}
