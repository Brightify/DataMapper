//
//  Double+SupportedTypeConvertible.swift
//  DataMapper
//
//  Created by Filip Dolnik on 21.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

extension Double: SupportedTypeConvertible {
    
    public static var defaultTransformation = DoubleTransformation().typeErased()
}
