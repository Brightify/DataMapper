//
//  SupportedNumber+Equatable.swift
//  DataMapper
//
//  Created by Filip Dolnik on 30.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

extension SupportedNumber: Equatable {
}

public func ==(lhs: SupportedNumber, rhs: SupportedNumber) -> Bool {
    return lhs.bool == rhs.bool && lhs.int == rhs.int && lhs.double == rhs.double
}
