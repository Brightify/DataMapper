//
//  Double+SupportedTypeConvertibleTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 31.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class Double_SupportedTypeConvertibleTest: QuickSpec {
    
    override func spec() {
        describe("Double") {
            it("can be used in ObjectMapper without transformation") {
                let objectMapper = ObjectMapper()
                let value = 1.1
                let type: SupportedType = .double(1.1)
                
                expect(objectMapper.deserialize(type)) == value
                expect(objectMapper.serialize(value)) == type
            }
        }
    }
}
