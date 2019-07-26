//
//  URL+SupportedTypeConvertibleTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 31.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper
import Foundation

class URL_SupportedTypeConvertibleTest: QuickSpec {
    
    override func spec() {
        describe("URL") {
            it("can be used in ObjectMapper without transformation") {
                let objectMapper = ObjectMapper()
                let value = URL(string: "a")
                let type: SupportedType = .string("a")
                
                expect(try? objectMapper.deserialize(URL.self, from: type)) == value
                expect(objectMapper.serialize(value)) == type
            }
        }
    }
}
