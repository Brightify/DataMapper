//
//  BoolPreference.swift
//  Pods
//
//  Created by Filip Dolník on 25.05.15.
//
//

import Foundation

public class BoolPreferenceImpl<T>: Preference<Bool> {
    
    override var valueDelegate: Bool {
        get {
            return preferences.boolForKey(key)
        } set {
            preferences.setBool(newValue, forKey: key)
        }
    }
    
    public override init(key: String, defaultValue: Bool = false) {
        super.init(key: key, defaultValue: defaultValue)
    }
    
}

public typealias BoolPreference = BoolPreferenceImpl<Bool>