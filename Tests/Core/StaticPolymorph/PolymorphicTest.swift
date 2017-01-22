//
//  PolymorphicTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 24.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
@testable import DataMapper

class PolymorphicTest: QuickSpec {
    
    private typealias A = TestData.StaticPolymorph.A
    
    override func spec() {
        describe("Polymorphic extension") {
            describe("defaultName") {
                it("returns name of class") {
                    expect(PolymorphicClass.defaultName) == "PolymorphicClass"
                }
                it("returns name of class if type is private") {
                    expect(PrivatePolymorphicClass.defaultName) == "PrivatePolymorphicClass"
                }
            }
            describe("createPolymorphicInfo") {
                it("creates GenericPolymorphicInfo of type Self named as type") {
                    let info = A.createPolymorphicInfo()
                    
                    expect(info.name) == "A"
                    expect("\(info.type)") == "\(A.self)"
                }
            }
            describe("createPolymorphicInfo(String)") {
                it("creates GenericPolymorphicInfo of type Self named as parameter") {
                    let info = A.createPolymorphicInfo(name: "Name")
                    
                    expect(info.name) == "Name"
                    expect("\(info.type)") == "\(A.self)"
                }
            }
        }
    }
    
    class PolymorphicClass: Polymorphic {
        
        static let polymorphicKey = "K"
        
        static let polymorphicInfo: PolymorphicInfo = createPolymorphicInfo()
    }
    
    private class PrivatePolymorphicClass: Polymorphic {
        
        static let polymorphicKey = "K"
        
        static let polymorphicInfo: PolymorphicInfo = createPolymorphicInfo()
    }
}
