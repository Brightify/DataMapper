//
//  Int+Functionals.swift
//  Pods
//
//  Created by Tadeas Kriz on 27/07/15.
//
//

internal extension Int {
    
    internal func times(@noescape closure: () -> ()) {
        for i in 0..<self {
            closure()
        }
    }
    
}