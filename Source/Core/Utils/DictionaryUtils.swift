//
//  DictionaryUtils.swift
//  DataMapper
//
//  Created by Filip Dolnik on 28.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

extension Dictionary {
    
    func mapValueOrNil<V>(_ transform: (Value) -> V?) -> [Key: V]? {
        var output = Dictionary<Key, V>(minimumCapacity: count)
        for (key, value) in self {
            if let mappedValue: V = transform(value) {
                output[key] = mappedValue
            } else {
                return nil
            }
        }
        return output
    }
}
