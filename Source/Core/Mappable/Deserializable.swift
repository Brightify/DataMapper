//
//  Deserializable.swift
//  DataMapper
//
//  Created by Filip Dolnik on 23.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol Deserializable {
    
    init(_ data: DeserializableData) throws
}

extension Array: Deserializable where Element: Deserializable {
    public init(_ data: DeserializableData) throws {
        self = try data.objectMapper.deserializeArray(data.raw)
    }
}

extension Optional: Deserializable where Wrapped: Deserializable {
    public init(_ data: DeserializableData) throws {
        self = try data.objectMapper.deserializeOptional(data.raw)
    }
}

extension Dictionary: Deserializable where Key == String, Value: Deserializable {
    public init(_ data: DeserializableData) throws {
        self = try data.objectMapper.deserializeDictionary(data.raw)
    }
}
