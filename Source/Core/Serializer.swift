//
//  Serializer.swift
//  DataMapper
//
//  Created by Filip Dolnik on 28.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public protocol Serializer {
    
    func serialize(_ supportedType: SupportedType) -> Data
    
    func deserialize(_ data: Data) -> SupportedType
}

extension Serializer {
    
    public func serialize(toString supportedType: SupportedType) -> String {
        return String(data: serialize(supportedType), encoding: .utf8) ?? ""
    }
    
    public func deserialize(fromString string: String) -> SupportedType {
        return deserialize(string.data(using: .utf8) ?? Data())
    }
}
