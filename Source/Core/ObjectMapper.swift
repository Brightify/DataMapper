//
//  ObjectMapper.swift
//  DataMapper
//
//  Created by Filip Dolnik on 28.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public final class ObjectMapper {
    
    private let polymorph: Polymorph?
    
    public init(polymorph: Polymorph? = nil) {
        self.polymorph = polymorph
    }
    
    public func serialize<T: Serializable>(_ value: T?) -> SupportedType {
        if let value = value {
            var serializableData = SerializableData(objectMapper: self)
            value.serialize(to: &serializableData)
            var data = serializableData.raw
            polymorph?.writeTypeInfo(to: &data, of: type(of: value))
            return data
        } else {
            return .null
        }
    }
    
    public func serialize<T: Serializable>(_ array: [T?]?) -> SupportedType {
        if let array = array {
            return .array(array.map(serialize))
        } else {
            return .null
        }
    }
    
    public func serialize<T: Serializable>(_ dictionary: [String: T?]?) -> SupportedType {
        if let dictionary = dictionary {
            return .dictionary(dictionary.mapValues(serialize))
        } else {
            return .null
        }
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
    
    public func deserialize<T: Deserializable>(_ type: SupportedType) -> T? {
        let data = DeserializableData(data: type, objectMapper: self)
        let type = polymorph?.polymorphType(for: T.self, in: type) ?? T.self
        return try? type.init(data)
    }
    
    public func deserialize<T: Deserializable>(_ type: SupportedType) -> [T]? {
        guard let array = type.array else {
            return nil
        }
        
        return array.mapOrNil(deserialize)
    }
    
    public func deserialize<T: Deserializable>(_ type: SupportedType) -> [T?]? {
        return type.array?.map(deserialize)
    }
    
    public func deserialize<T: Deserializable>(_ type: SupportedType) -> [String: T]? {
        guard let dictionary = type.dictionary else {
            return nil
        }
        
        return dictionary.mapValueOrNil(deserialize)
    }
    
    public func deserialize<T: Deserializable>(_ type: SupportedType) -> [String: T?]? {
        return type.dictionary?.mapValues(deserialize)
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
}
