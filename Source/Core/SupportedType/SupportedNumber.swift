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
    
    public init(bool: Bool) {
        self.bool = bool
        self.int = nil
        self.double = nil
    }
    
    public init(int: Int) {
        self.bool = nil
        self.int = int
        self.double = nil
    }
    
    public init(double: Double) {
        self.bool = nil
        self.int = nil
        self.double = double
    }
    
    public init(bool: Bool, int: Int) {
        self.bool = bool
        self.int = int
        self.double = nil
    }
    
    public init(bool: Bool, double: Double) {
        self.bool = bool
        self.int = nil
        self.double = double
    }
    
    public init(int: Int, double: Double) {
        self.bool = nil
        self.int = int
        self.double = double
    }
    
    public init(bool: Bool, int: Int, double: Double) {
        self.bool = bool
        self.int = int
        self.double = double
    }
}
