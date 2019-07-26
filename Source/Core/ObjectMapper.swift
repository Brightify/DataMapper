//
//  ObjectMapper.swift
//  DataMapper
//
//  Created by Filip Dolnik on 28.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public final class ObjectMapper {
    
    private let polymorph: Polymorph?
    
    public init(polymorph: Polymorph? = nil) {
        self.polymorph = polymorph
    }
    
    public func serialize<T: Serializable>(_ value: T) -> SupportedType {
        var serializableData = SerializableData(objectMapper: self)
        value.serialize(to: &serializableData)
        var data = serializableData.raw
        polymorph?.writeTypeInfo(to: &data, of: type(of: value))
        return data
    }
    
    internal func serialize<T: Serializable>(array: [T], to storage: inout SupportedType) {
        storage.array = array.map {
            serialize($0)
        }
    }

    internal func serialize<T: Serializable>(optional: T?, to storage: inout SupportedType) {
        if let value = optional {
            storage = serialize(value)
        } else {
            storage.setNull()
        }
    }
    
    internal func serialize<T: Serializable>(dictionary: [String: T], to storage: inout SupportedType) {
        storage.dictionary = dictionary.mapValues(serialize)
    }
    
    public func serialize<T, R: SerializableTransformation>(_ value: T?, using transformation: R) -> SupportedType where R.Object == T {
        return transformation.transform(object: value)
    }
    
    public func serialize<T, R: SerializableTransformation>(_ array: [T?]?, using transformation: R) -> SupportedType where R.Object == T {
        if let array = array {
            return .array(array.map(transformation.transform(object:)))
        } else {
            return .null
        }
    }
    
    public func serialize<T, R: SerializableTransformation>(_ dictionary: [String: T?]?, using transformation: R) -> SupportedType where R.Object == T {
        if let dictionary = dictionary {
            return .dictionary(dictionary.mapValues(transformation.transform(object:)))
        } else {
            return .null
        }
    }

    public func encode<T : Encodable>(_ value: T) throws -> SupportedType {
        let encoder = ObjectMapperEncoding()
        try value.encode(to: encoder)
        return encoder.storage
    }
    
    public func deserialize<T: Deserializable>(_ type: T.Type, from storage: SupportedType) throws -> T {
        let data = DeserializableData(data: storage, objectMapper: self)
        let type = polymorph?.polymorphType(for: T.self, in: storage) ?? T.self
        return try type.init(data)
    }
    
    internal func deserializeArray<T: Deserializable>(_ storage: SupportedType) throws -> [T] {
        guard let array = storage.array else {
            throw DeserializationError.wrongType(expected: .array, actual: storage)
        }
        
        return try array.map {
            try deserialize(T.self, from: $0)
        }
    }

    internal func deserializeOptional<T: Deserializable>(_ type: SupportedType) throws -> T? {
        if type.isNull {
            return nil
        } else {
            return try deserialize(T.self, from: type)
        }
    }
    
    internal func deserializeDictionary<T: Deserializable>(_ type: SupportedType) throws -> [String: T] {
        guard let dictionary = type.dictionary else {
            throw DeserializationError.wrongType(expected: .dictionary, actual: type)
        }
        
        return try dictionary.mapValues {
            try deserialize(T.self, from: $0)
        }
    }
    
    public func deserialize<T, R: DeserializableTransformation>(_ type: SupportedType, using transformation: R) -> T? where R.Object == T {
        return transformation.transform(from: type)
    }
    
    public func deserialize<T, R: DeserializableTransformation>(_ type: SupportedType, using transformation: R) -> [T]? where R.Object == T {
        guard let array = type.array else {
            return nil
        }
        
        return array.mapOrNil(transformation.transform(from:))
    }
    
    public func deserialize<T, R: DeserializableTransformation>(_ type: SupportedType, using transformation: R) -> [T?]? where R.Object == T {
        return type.array?.map(transformation.transform(from:))
    }
    
    public func deserialize<T, R: DeserializableTransformation>(_ type: SupportedType, using transformation: R) -> [String: T]? where R.Object == T {
        guard let dictionary = type.dictionary else {
            return nil
        }
        
        return dictionary.mapValueOrNil(transformation.transform(from:))
    }
    
    public func deserialize<T, R: DeserializableTransformation>(_ type: SupportedType, using transformation: R) -> [String: T?]? where R.Object == T {
        return type.dictionary?.mapValues(transformation.transform(from:))
    }

    public func decode<T: Decodable>(_ type: T.Type, from supportedType: SupportedType) throws -> T {
        let decoder = ObjectMapperDecoding(storage: supportedType)
        return try type.init(from: decoder)
    }
}

private struct ObjectMapperKey {

}

public final class ObjectEncoder {
    private let objectMapper: ObjectMapper
    private let serializer: Serializer

    public init(objectMapper: ObjectMapper = ObjectMapper(), serializer: Serializer) {
        self.objectMapper = objectMapper
        self.serializer = serializer
    }

    /// Encodes the given top-level value and returns its JSON representation.
    ///
    /// - parameter value: The value to encode.
    /// - returns: A new `Data` value containing the encoded JSON data.
    /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - throws: An error if any value throws an error during encoding.
    public func encode<T : Encodable>(_ value: T) throws -> Data {
        return try serializer.serialize(objectMapper.encode(value))
//        guard let topLevel = try encoder.box_(value) else {
//            throw EncodingError.invalidValue(value,
//                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
//        }
//
//        if topLevel is NSNull {
//            throw EncodingError.invalidValue(value,
//                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as null JSON fragment."))
//        } else if topLevel is NSNumber {
//            throw EncodingError.invalidValue(value,
//                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as number JSON fragment."))
//        } else if topLevel is NSString {
//            throw EncodingError.invalidValue(value,
//                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as string JSON fragment."))
//        }
//
//        let writingOptions = JSONSerialization.WritingOptions(rawValue: self.outputFormatting.rawValue)
//        do {
//            return try JSONSerialization.data(withJSONObject: topLevel, options: writingOptions)
//        } catch {
//            throw EncodingError.invalidValue(value,
//                                             EncodingError.Context(codingPath: [], debugDescription: "Unable to encode the given top-level value to JSON.", underlyingError: error))
//        }
    }

}

private final class ObjectMapperEncoding: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]

    let storage: SupportedType

    init(storage: SupportedType = .null) {
        self.storage = storage
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = ObjectMapperKeyedEncodingContainer<Key>(storage: storage)
        container.codingPath = codingPath
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
//        let topStorage: SupportedType

        return ObjectMapperUnkeyedEncodingContainer(codingPath: codingPath, storage: storage)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = ObjectMapperSingleValueEncodingContainer(storage: storage)
        container.codingPath = codingPath
        return container
    }
}

private final class ObjectMapperSingleValueEncodingContainer: SingleValueEncodingContainer {
    var codingPath: [CodingKey] = []

    private let storage: SupportedType

    init(storage: SupportedType = .null) {
        self.storage = storage
    }

    fileprivate var canEncodeNewValue: Bool {
        #warning("Not implemented!")
        return true
    }

    private func assertCanEncodeNewValue() {
        precondition(canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }

    func encodeNil() throws {
        assertCanEncodeNewValue()
        storage.setNull()
    }

    func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        storage.bool = value
    }

    func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        storage.string = value
    }

    func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        storage.double = value
    }

    func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        storage.double = Double(value)
    }

    func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        storage.int = value
    }

    func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        storage.int = Int(value)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        assertCanEncodeNewValue()
        let encoding = ObjectMapperEncoding(storage: storage)
        encoding.codingPath = codingPath
        try value.encode(to: encoding)
    }
}

private final class ObjectMapperKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K

    var codingPath: [CodingKey] = []

    private let storage: SupportedType

    init(storage: SupportedType) {
        self.storage = storage
    }

    private func converted(key: CodingKey) -> CodingKey {
        return key
    }

    func encodeNil(forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .null)
    }

    func encode(_ value: Bool, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .bool(value))
    }

    func encode(_ value: String, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .string(value))
    }

    func encode(_ value: Double, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .double(value))
    }

    func encode(_ value: Float, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .double(Double(value)))
    }

    func encode(_ value: Int, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(value))
    }

    func encode(_ value: Int8, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode(_ value: Int16, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode(_ value: Int32, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode(_ value: Int64, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode(_ value: UInt, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode(_ value: UInt8, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode(_ value: UInt16, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode(_ value: UInt32, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode(_ value: UInt64, forKey key: K) throws {
        storage.addToDictionary(key: converted(key: key).stringValue, value: .int(Int(value)))
    }

    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        let encoding = ObjectMapperEncoding()
        encoding.codingPath.append(key)
        try value.encode(to: encoding)
        storage.addToDictionary(key: converted(key: key).stringValue, value: encoding.storage)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let containerKey = converted(key: key).stringValue
        let dictionary: SupportedType
        if let existingContainer = storage.dictionary?[containerKey] {
            precondition(existingContainer.dictionary != nil, "Attempt to re-encode into nested KeyedEncodingContainer<\(Key.self)> for key \"\(containerKey)\" is invalid: non-keyed container already encoded for this key")
            dictionary = existingContainer
        } else {
            dictionary = .dictionary([:])
            storage.addToDictionary(key: containerKey, value: dictionary)
        }

        codingPath.append(key)
        defer { codingPath.removeLast() }

        let container = ObjectMapperKeyedEncodingContainer<NestedKey>(storage: dictionary)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let containerKey = converted(key: key).stringValue
        let array: SupportedType
        if let existingContainer = storage.dictionary?[containerKey] {
            precondition(existingContainer.array != nil, "Attempt to re-encode into nested UnkeyedEncodingContainer for key \"\(containerKey)\" is invalid: keyed container/single value already encoded for this key")
            array = existingContainer
        } else {
            array = .array([])
            storage.addToDictionary(key: containerKey, value: array)
        }

        codingPath.append(key)
        defer { codingPath.removeLast() }

        return ObjectMapperUnkeyedEncodingContainer(codingPath: codingPath, storage: array)
    }

    func superEncoder() -> Encoder {
        fatalError()
    }

    func superEncoder(forKey key: K) -> Encoder {
        fatalError()
    }
}

private final class ObjectMapperUnkeyedEncodingContainer: UnkeyedEncodingContainer {

    let storage: SupportedType
    let codingPath: [CodingKey]

    init(codingPath: [CodingKey], storage: SupportedType) {
        self.codingPath = codingPath
        self.storage = storage
    }

    var count: Int {
        return storage.array?.count ?? 0
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        #warning("Not implemented!")
        fatalError("Not implemented.")
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
//        codingPath.append()
        fatalError()
    }

    func superEncoder() -> Encoder {
        #warning("Not implemented!")
        fatalError("Not implemented.")
    }

    func encodeNil() throws {
        storage.appendToArray(value: .null)
    }

    func encode(_ value: Bool) throws {
        storage.appendToArray(value: .bool(value))
    }

    func encode(_ value: String) throws {
        storage.appendToArray(value: .string(value))
    }

    func encode(_ value: Double) throws {
        storage.appendToArray(value: .double(value))
    }

    func encode(_ value: Float) throws {
        storage.appendToArray(value: .double(Double(value)))
    }

    func encode(_ value: Int) throws {
        storage.appendToArray(value: .int(value))
    }

    func encode(_ value: Int8) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode(_ value: Int16) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode(_ value: Int32) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode(_ value: Int64) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode(_ value: UInt) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode(_ value: UInt8) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode(_ value: UInt16) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode(_ value: UInt32) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode(_ value: UInt64) throws {
        storage.appendToArray(value: .int(Int(value)))
    }

    func encode<T>(_ value: T) throws where T : Encodable {

        #warning("CodingKey push not implemented!")

        let encoding = ObjectMapperEncoding(storage: .dictionary([:]))
        try value.encode(to: encoding)
        storage.appendToArray(value: encoding.storage)
    }

}


public final class ObjectDecoder {
    private let objectMapper: ObjectMapper
    private let serializer: Serializer

    public init(objectMapper: ObjectMapper = ObjectMapper(), serializer: Serializer) {
        self.objectMapper = objectMapper
        self.serializer = serializer
    }

    /// Encodes the given top-level value and returns its JSON representation.
    ///
    /// - parameter value: The value to encode.
    /// - returns: A new `Data` value containing the encoded JSON data.
    /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - throws: An error if any value throws an error during encoding.
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        return try objectMapper.decode(type, from: serializer.deserialize(data))
        //        guard let topLevel = try encoder.box_(value) else {
        //            throw EncodingError.invalidValue(value,
        //                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
        //        }
        //
        //        if topLevel is NSNull {
        //            throw EncodingError.invalidValue(value,
        //                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as null JSON fragment."))
        //        } else if topLevel is NSNumber {
        //            throw EncodingError.invalidValue(value,
        //                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as number JSON fragment."))
        //        } else if topLevel is NSString {
        //            throw EncodingError.invalidValue(value,
        //                                             EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as string JSON fragment."))
        //        }
        //
        //        let writingOptions = JSONSerialization.WritingOptions(rawValue: self.outputFormatting.rawValue)
        //        do {
        //            return try JSONSerialization.data(withJSONObject: topLevel, options: writingOptions)
        //        } catch {
        //            throw EncodingError.invalidValue(value,
        //                                             EncodingError.Context(codingPath: [], debugDescription: "Unable to encode the given top-level value to JSON.", underlyingError: error))
        //        }
    }

}

private final class ObjectMapperDecoding: Decoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    private let storage: SupportedType

    init(storage: SupportedType) {
        self.storage = storage
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(ObjectMapperKeyedDecodingContainer<Key>(storage: storage))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return ObjectMapperUnkeyedDecodingContainer(storage: storage)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ObjectMapperSingleValueDecodingContainer(storage: storage)
    }
}

private final class ObjectMapperKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    var codingPath: [CodingKey] = []

    var allKeys: [K] {
        return storage.dictionary?.keys.compactMap { Key(stringValue: $0) } ?? []
    }

    private let storage: SupportedType

    init(storage: SupportedType) {
        self.storage = storage
    }

    private func converted(key: CodingKey) -> CodingKey {
        return key
    }

    private func item(forKey key: K, _ type: Any.Type) throws -> SupportedType {
        guard let item = storage.dictionary?[converted(key: key).stringValue] else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key \(key)."))
        }
        return item
    }

    private func require<T>(_ optionalValue: T?) throws -> T {
        guard let value = optionalValue else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "FIXME"))
        }
        return value
    }

    func contains(_ key: K) -> Bool {
        return storage.dictionary?.keys.contains(converted(key: key).stringValue) ?? false
    }

    func decodeNil(forKey key: K) throws -> Bool {
        return try item(forKey: key, Any?.self).isNull
    }

    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        return try require(item(forKey: key, type).bool)
    }

    func decode(_ type: String.Type, forKey key: K) throws -> String {
        return try require(item(forKey: key, type).string)
    }

    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        return try require(item(forKey: key, type).double)
    }

    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        return try Float(require(item(forKey: key, type).double))
    }

    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        return try require(item(forKey: key, type).int)
    }

    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        return try Int8(require(item(forKey: key, type).int))
    }

    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        return try Int16(require(item(forKey: key, type).int))
    }

    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        return try Int32(require(item(forKey: key, type).int))
    }

    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        return try Int64(require(item(forKey: key, type).int))
    }

    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        return try UInt(require(item(forKey: key, type).int))
    }

    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        return try UInt8(require(item(forKey: key, type).int))
    }

    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        return try UInt16(require(item(forKey: key, type).int))
    }

    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        return try UInt32(require(item(forKey: key, type).int))
    }

    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        return try UInt64(require(item(forKey: key, type).int))
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        let decoding = ObjectMapperDecoding(storage: try item(forKey: key, type))
        return try type.init(from: decoding)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        fatalError()
    }


}

private struct ObjectMapperUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] = []

    var count: Int? {
        return storage.array?.count
    }

    var isAtEnd: Bool {
        guard let count = count else { return true }
        return currentIndex >= count
    }

    private(set) var currentIndex: Int = 0


    private let storage: SupportedType

    init(storage: SupportedType) {
        self.storage = storage
    }

    private func validateNotEnded(_ type: Any.Type) throws {
        if isAtEnd {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Unkeyed container is at end."))
        }
    }

    private var currentItem: SupportedType {
        return storage.array![currentIndex]
    }

    private mutating func require<T>(_ optionalValue: T?) throws -> T {
        guard let value = optionalValue else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "FIXME"))
        }
        currentIndex += 1
        return value
    }

    mutating func decodeNil() throws -> Bool {
        try validateNotEnded(Any?.self)

        if currentItem.isNull {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        try validateNotEnded(type)

        return try require(currentItem.bool)
    }

    mutating func decode(_ type: String.Type) throws -> String {
        try validateNotEnded(type)

        return try require(currentItem.string)
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        try validateNotEnded(type)

        return try require(currentItem.double)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        try validateNotEnded(type)

        return try Float(require(currentItem.double))
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        try validateNotEnded(type)

        return try require(currentItem.int)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try validateNotEnded(type)

        return try Int8(require(currentItem.int))
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try validateNotEnded(type)

        return try Int16(require(currentItem.int))
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try validateNotEnded(type)

        return try Int32(require(currentItem.int))
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try validateNotEnded(type)

        return try Int64(require(currentItem.int))
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        try validateNotEnded(type)

        return try UInt(require(currentItem.int))
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try validateNotEnded(type)

        return try UInt8(require(currentItem.int))
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try validateNotEnded(type)

        return try UInt16(require(currentItem.int))
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try validateNotEnded(type)

        return try UInt32(require(currentItem.int))
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try validateNotEnded(type)

        return try UInt64(require(currentItem.int))
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try validateNotEnded(type)

        let decoding = ObjectMapperDecoding(storage: currentItem)
        let decoded = try type.init(from: decoding)
        currentIndex += 1
        return decoded
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    mutating func superDecoder() throws -> Decoder {
        fatalError()
    }
}

private final class ObjectMapperSingleValueDecodingContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    private let storage: SupportedType

    init(storage: SupportedType) {
        self.storage = storage
    }

    private func require<T>(_ optionalValue: T?) throws -> T {
        guard let value = optionalValue else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "FIXME"))
        }
        return value
    }

    func decodeNil() -> Bool {
        return storage.isNull
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try require(storage.bool)
    }

    func decode(_ type: String.Type) throws -> String {
        return try require(storage.string)
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try require(storage.double)
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try Float(require(storage.double))
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try require(storage.int)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try Int8(require(storage.int))
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try Int16(require(storage.int))
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try Int32(require(storage.int))
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try Int64(require(storage.int))
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try UInt(require(storage.int))
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try UInt8(require(storage.int))
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try UInt16(require(storage.int))
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try UInt32(require(storage.int))
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try UInt64(require(storage.int))
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoding = ObjectMapperDecoding(storage: storage)
        return try type.init(from: decoding)
    }


}
