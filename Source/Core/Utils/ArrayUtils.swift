//
//  ArrayUtils.swift
//  DataMapper
//
//  Created by Filip Dolnik on 09.03.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

extension Array {
    
    public func mapOrNil<T>(_ transform: (Element) -> T?) -> [T]? {
        var output = ContiguousArray<T>()
        output.reserveCapacity(count)
        
        var i = startIndex
        for _ in 0..<count {
            if let mappedValue: T = transform(self[i]) {
                output.append(mappedValue)
                formIndex(after: &i)
            } else {
                return nil
            }
        }
        
        return Array<T>(output)
    }
}
