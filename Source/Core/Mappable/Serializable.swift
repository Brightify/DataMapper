//
//  Serializable.swift
//  DataMapper
//
//  Created by Filip Dolnik on 23.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol Serializable {
    
    func serialize(to data: inout SerializableData)
}

extension Array: Serializable where Element: Serializable {
    public func serialize(to data: inout SerializableData) {
        data.objectMapper.serialize(array: self, to: &data.raw)
    }
}

extension Optional: Serializable where Wrapped: Serializable {
    public func serialize(to data: inout SerializableData) {
        data.objectMapper.serialize(optional: self, to: &data.raw)
    }
}

extension Dictionary: Serializable where Key == String, Value: Serializable {
    public func serialize(to data: inout SerializableData) {
        data.objectMapper.serialize(dictionary: self, to: &data.raw)
    }
}
