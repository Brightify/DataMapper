//
//  SupportedNumber.swift
//  DataMapper
//
//  Created by Filip Dolnik on 30.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct SupportedNumber {
    
    public let bool: Bool?
    public let int: Int?
    public let double: Double?

    public init(bool: Bool? = nil, int: Int? = nil, double: Double? = nil) {
        self.bool = bool
        self.int = int
        self.double = double
    }
}
