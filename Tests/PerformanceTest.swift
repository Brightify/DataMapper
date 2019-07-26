//
//  PerformanceTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 27.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import XCTest
import DataMapper
import IkigaJSON

class PerformanceTest: XCTestCase {
    
    private typealias Object = TestData.PerformanceStruct
    
    private let objectMapper = ObjectMapper()
    private let serializer = JsonSerializer()
    private let objectEncoder = ObjectEncoder(serializer: JsonSerializer())
    private let objectDecoder = ObjectDecoder(serializer: JsonSerializer())
    private let objects = TestData.generate(x: 8)
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let ikigaJsonEncoder = IkigaJSONEncoder()
    private let ikigaJsonDecoder = IkigaJSONDecoder()

    // MARK:- Deserialization tests
    /// Pure Swift Codable
    func testDerializeDataToCodable() {
        let data = try! jsonEncoder.encode(objects)
        var result: Object!
        measure {
            result = try! jsonDecoder.decode(TestData.PerformanceStruct.self, from: data)
        }
        _ = result
    }

    /// IkigaJSON Codable
    func _testDerializeDataToCodableUsingIkiga() {
        let data = try! ikigaJsonEncoder.encode(objects)

        var result: Object!
//        measure {
            result = try! ikigaJsonDecoder.decode(TestData.PerformanceStruct.self, from: data)
//        }
        _ = result
    }

    /// DataMapper
    func testDeserializeDataToObject() {
        let data: Data = serializer.serialize(objectMapper.serialize(objects))
        var result: Object!
        measure {
            result = self.objectMapper.deserialize(self.serializer.deserialize(data))
        }
        _ = result
    }

    func testDeserializeDataToCodableObject() {
        let data: Data = serializer.serialize(objectMapper.serialize(objects))
        var result: Object!
        measure {
            result = try! self.objectDecoder.decode(Object.self, from: data)
        }
        _ = result
    }

    func _testDeserializeDataToSupportedType() {
        let data: Data = serializer.serialize(objectMapper.serialize(objects))
        var result: SupportedType!
        measure {
            result = self.serializer.deserialize(data)
        }
        _ = result
    }

    func _testDeserializeSupportedTypeToObject() {
        let data: SupportedType = objectMapper.serialize(objects)
        var result: Object!
        measure {
            result = self.objectMapper.deserialize(data)
        }
        _ = result
    }

    // Serialization
    /// Pure Swift Codable
    func testSerializeCodableToData() {
        var result: Data!
        measure {
            result = try! jsonEncoder.encode(self.objects)
        }
        _ = result
    }

    /// IkigaJSON Codable
    func _testSerializeCodableToDataUsingIkiga() {
        var result: Data!
        measure {
            result = try! ikigaJsonEncoder.encode(self.objects)
        }
        _ = result
    }

    /// DataMapper
    func testSerializeObjectToData() {
        let data: Object = objects
        var result: Data!
        measure {
            result = self.serializer.serialize(self.objectMapper.serialize(data))
        }
        _ = result
    }

    func testSerializeCodableObjectToData() {
        let data: Object = objects
        var result: Data!
        measure {
            result = try! self.objectEncoder.encode(data)
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
