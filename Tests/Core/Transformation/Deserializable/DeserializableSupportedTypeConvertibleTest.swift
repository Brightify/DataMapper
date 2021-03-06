//
//  DeserializableSupportedTypeConvertibleTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 27.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class DeserializableSupportedTypeConvertibleTest: QuickSpec {
    
    override func spec() {
        describe("DeserializableSupportedTypeConvertible") {
            it("can be used in ObjectMapper without transformation") {
                let objectMapper = ObjectMapper()
                let value: DeserializableSupportedTypeConvertibleStub? = DeserializableSupportedTypeConvertibleStub()
                let type: SupportedType = .null
                
                let result: DeserializableSupportedTypeConvertibleStub? = objectMapper.deserialize(type)
                expect(String(describing: result)) == String(describing: value)
            }
        }
    }
    
    private struct DeserializableSupportedTypeConvertibleStub: DeserializableSupportedTypeConvertible {
        
        static let defaultDeserializableTransformation: AnyDeserializableTransformation<DeserializableSupportedTypeConvertibleStub> =
            AnyDeserializableTransformation(transformFrom: { _ in DeserializableSupportedTypeConvertibleStub() })
    }
}
