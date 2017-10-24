//
//  PerformanceTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 27.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import DataMapper

class PerformanceTest: XCTestCase {
    
    private typealias Object = TestData.PerformanceStruct
    
    private let objectMapper = ObjectMapper()
    private let serializer = JsonSerializer()
    private let objects = TestData.generate(x: 8)
    
    func testDerializeDataToCodable() {
        let data = try! JSONEncoder().encode(objects)
        var result: Object!
        measure {
            result = try! JSONDecoder().decode(TestData.PerformanceStruct.self, from: data)
        }
        _ = result
    }
    
    func testSerializeCodableToData() {
        var result: Data!
        measure {
            result = try! JSONEncoder().encode(self.objects)
        }
        _ = result
    }

    func testDeserializeDataToObject() {
        let data: Data = serializer.serialize(objectMapper.serialize(objects))
        var result: Object!
        measure {
            result = self.objectMapper.deserialize(self.serializer.deserialize(data))
        }
        _ = result
    }
    
    func testDeserializeSupportedTypeToObject() {
        let data: SupportedType = objectMapper.serialize(objects)
        var result: Object!
        measure {
            result = self.objectMapper.deserialize(data)
        }
        _ = result
    }
    
    func testDeserializeDataToSupportedType() {
        let data: Data = serializer.serialize(objectMapper.serialize(objects))
        var result: SupportedType!
        measure {
            result = self.serializer.deserialize(data)
        }
        _ = result
    }
    
    func testSerializeObjectToData() {
        let data: Object = objects
        var result: Data!
        measure {
            result = self.serializer.serialize(self.objectMapper.serialize(data))
        }
        _ = result
    }
    
    func testSerializeObjectToSupportedType() {
        let data: Object = objects
        var result: SupportedType!
        measure {
            result = self.objectMapper.serialize(data)
        }
        _ = result
    }
    
    func testSerializeSupportedTypeToData() {
        let data: SupportedType = objectMapper.serialize(objects)
        var result: Data!
        measure {
            result = self.serializer.serialize(data)
        }
        _ = result
    }
    
    
    
    // TODO Change Any
    func testTypedSerialize() {
        let data: SupportedType = objectMapper.serialize(objects)
        var result: Any!
        measure {
            result = self.serializer.typedSerialize(data)
        }
        _ = result
    }
    
    func testTypedDeserialize() {
        let data: Any = serializer.typedSerialize(objectMapper.serialize(objects))
        var result: SupportedType!
        measure {
            result = self.serializer.typedDeserialize(data)
        }
        _ = result
    }
    
    
    
    
    // TODO Improve to use Swift objects
    func _testSerializeFoundation() {
        let data: Any = try! JSONSerialization.jsonObject(with: serializer.serialize(objectMapper.serialize(objects)), options: .allowFragments)
        var result: Data!
        measure {
            result = try! JSONSerialization.data(withJSONObject: data)
        }
        _ = result
    }
    
    func _testDeserializeFoundation() {
        let data: Data = serializer.serialize(objectMapper.serialize(objects))
        var result: Any!
        measure {
            result = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
        _ = result
    }
}
