//
//  DeserializationError.swift
//  DataMapper
//
//  Created by Filip Dolnik on 30.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public enum DeserializationError: Error {
    case wrongType(type: SupportedType, expected: SupportedType.RawType)
    case custom(Error)
    case unknown

    public static func wrongType(expected: SupportedType.RawType, actual: SupportedType) -> DeserializationError {
        return DeserializationError.wrongType(type: actual, expected: expected)
    }
}
