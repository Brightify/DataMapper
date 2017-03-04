//
//  SupportedType+Equatable.swift
//  DataMapper
//
//  Created by Filip Dolnik on 30.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import DataMapper

extension SupportedType: Equatable {
}

public func ==(lhs: SupportedType, rhs: SupportedType) -> Bool {
    if let lhsDictionary = lhs.dictionary, let rhsDictionary = rhs.dictionary {
        return lhsDictionary == rhsDictionary
    } else {
        return String(describing: lhs.raw) == String(describing: rhs.raw)
    }
}
