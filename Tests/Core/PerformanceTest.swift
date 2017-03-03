//
//  PerformanceTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 27.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import DataMapper

class PerfomanceTest: XCTestCase {
    
    private typealias Object = TestData.PerformanceStruct
    
    private let objectMapper = ObjectMapper()
    private let serializer = JsonSerializer()
    private let objects = TestData.generate(x: 7)
    
    func testSerializeObjectToData() {
        let data: Object = objects
        var result: Data! = nil
        measure {
             result = self.serializer.serialize(self.objectMapper.serialize(data))
        }
        _ = result
    }
    
    func testDeserializeDataToObject() {
        let data: Data = serializer.serialize(objectMapper.serialize(objects))
        var result: Object! = nil
        measure {
            result = self.objectMapper.deserialize(self.serializer.deserialize(data))
        }
        _ = result
    }
    
    func testSerializeSupportedTypeToData() {
        let data: SupportedType = objectMapper.serialize(objects)
        var result: Data! = nil
        measure {
            result = self.serializer.serialize(data)
        }
        _ = result
    }
    
    func testDeserializeDataToSupportedType() {
        let data: Data = serializer.serialize(objectMapper.serialize(objects))
        var result: SupportedType = .null
        measure {
            result = self.serializer.deserialize(data)
        }
        _ = result
    }
    
    func testSerializeObjectToSupportedType() {
        let data: Object = objects
        var result: SupportedType = .null
        measure {
            result = self.objectMapper.serialize(data)
        }
        _ = result
    }
    
    func testDeserializeSupportedTypeToObject() {
        let data: SupportedType = objectMapper.serialize(objects)
        var result: Object! = nil
        measure {
            result = self.objectMapper.deserialize(data)
        }
        _ = result
    }
}
