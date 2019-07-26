//
//  DeserializableData.swift
//  DataMapper
//
//  Created by Filip Dolnik on 21.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct DeserializableData {
    
    public let raw: SupportedType
    public let objectMapper: ObjectMapper
    
    public init(data: SupportedType, objectMapper: ObjectMapper) {
        self.raw = data
        self.objectMapper = objectMapper
    }
    
    public subscript(path: [String]) -> DeserializableData {
        return DeserializableData(data: path.reduce(raw) { raw, path in
            raw.dictionary?[path] ?? .null
        }, objectMapper: objectMapper)
    }
    
    public subscript(path: String...) -> DeserializableData {
        return self[path]
    }
    
    public func get<T: Deserializable>(_ type: T.Type = T.self) throws -> T {
        return try objectMapper.deserialize(type, from: raw)
    }
    
    public func get<T: Deserializable>(or: T) -> T {
        do {
            return try get(T.self)
        } catch {
            return or
        }
    }

    public func get<T, R: DeserializableTransformation>(using transformation: R) -> T? where R.Object == T {
        return objectMapper.deserialize(raw, using: transformation)
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R, or: T) -> T where R.Object == T {
        return get(using: transformation) ?? or
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) throws -> T where R.Object == T {
        return try valueOrThrow(get(using: transformation))
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) -> [T]? where R.Object == T {
        return objectMapper.deserialize(raw, using: transformation)
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R, or: [T]) -> [T] where R.Object == T {
        return get(using: transformation) ?? or
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) throws -> [T] where R.Object == T {
        return try valueOrThrow(get(using: transformation))
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) -> [T?]? where R.Object == T {
        return objectMapper.deserialize(raw, using: transformation)
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R, or: [T?]) -> [T?] where R.Object == T {
        return get(using: transformation) ?? or
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) throws -> [T?] where R.Object == T {
        return try valueOrThrow(get(using: transformation))
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) -> [String: T]? where R.Object == T {
        return objectMapper.deserialize(raw, using: transformation)
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R, or: [String: T]) -> [String: T] where R.Object == T {
        return get(using: transformation) ?? or
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) throws -> [String: T] where R.Object == T {
        return try valueOrThrow(get(using: transformation))
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) -> [String: T?]? where R.Object == T {
        return objectMapper.deserialize(raw, using: transformation)
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R, or: [String: T?]) -> [String: T?] where R.Object == T {
        return get(using: transformation) ?? or
    }
    
    public func get<T, R: DeserializableTransformation>(using transformation: R) throws -> [String: T?] where R.Object == T {
        return try valueOrThrow(get(using: transformation))
    }
    
    public func valueOrThrow<T>(_ optionalValue: T?) throws -> T {
        if let value = optionalValue {
            return value
        } else {
            throw DeserializationError.wrongType(type: raw, expected: .null)
        }
    }
}
