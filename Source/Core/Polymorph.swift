//
//  Polymorph.swift
//  DataMapper
//
//  Created by Filip Dolnik on 28.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol Polymorph {
    
    /// Returns type to which the supportedType should be deserialized.
    func polymorphType<T>(for type: T.Type, in supportedType: SupportedType) -> T.Type
    
    /// Write info about the type to supportedType if necessary.
    func writeTypeInfo<T>(to supportedType: inout SupportedType, of type: T.Type)
}
