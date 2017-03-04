//
//  SupportedTypeTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 24.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class SupportedTypeTest: QuickSpec {
    
    override func spec() {
        describe("SupportedType") {
            describe("isNull") {
                it("returns true if is null") {
                    let type: SupportedType = .null
                    expect(type.isNull).to(beTrue())
                }
                it("returns false if is not null") {
                    let type: SupportedType = .bool(true)
                    expect(type.isNull).to(beFalse())
                }
            }
            describe("string") {
                it("returns string if is string") {
                    let type: SupportedType = .string("a")
                    expect(type.string) == "a"
                }
                it("returns nil if is not string") {
                    let type: SupportedType = .bool(true)
                    expect(type.string).to(beNil())
                }
            }
            describe("bool") {
                it("returns bool if is bool") {
                    let type: SupportedType = .bool(true)
                    expect(type.bool).to(beTrue())
                }
                it("returns nil if is not bool") {
                    let type: SupportedType = .int(1)
                    expect(type.bool).to(beNil())
                }
            }
            describe("int") {
                it("returns int if is int") {
                    let type: SupportedType = .int(1)
                    expect(type.int) == 1
                }
                it("returns nil if is not int") {
                    let type: SupportedType = .bool(true)
                    expect(type.int).to(beNil())
                }
            }
            describe("double") {
                it("returns double if is double") {
                    let type: SupportedType = .double(1)
                    expect(type.double) == 1
                }
                it("returns nil if is not double") {
                    let type: SupportedType = .bool(true)
                    expect(type.double).to(beNil())
                }
            }
            describe("array") {
                it("returns array if is array") {
                    let type: SupportedType = .array([.bool(true), .bool(false)])
                    expect(type.array) == [.bool(true), .bool(false)]
                }
                it("returns nil if is not array") {
                    let type: SupportedType = .bool(true)
                    expect(type.array).to(beNil())
                }
            }
            describe("dictionary") {
                it("returns dictionary if is dictionary") {
                    let type: SupportedType = .dictionary(["a": .bool(true), "b": .bool(false)])
                    expect(type.dictionary) == ["a": .bool(true), "b": .bool(false)]
                }
                it("returns nil if is not dictionary") {
                    let type: SupportedType = .bool(true)
                    expect(type.dictionary).to(beNil())
                }
            }
            describe("number") {
                it("returns number if is correct type") {
                    expect(SupportedType.number(bool: true, int: 1).bool).to(beTrue())
                    expect(SupportedType.number(bool: true, int: 1).int) == 1
                    
                    expect(SupportedType.number(bool: true, double: 1.1).bool).to(beTrue())
                    expect(SupportedType.number(bool: true, double: 1.1).double) == 1.1
                    
                    expect(SupportedType.number(int: 1, double: 1.1).int) == 1
                    expect(SupportedType.number(int: 1, double: 1.1).double) == 1.1
                    
                    expect(SupportedType.number(bool: true, int: 1, double: 1.1).bool).to(beTrue())
                    expect(SupportedType.number(bool: true, int: 1, double: 1.1).int) == 1
                    expect(SupportedType.number(bool: true, int: 1, double: 1.1).double) == 1.1
                }
                it("returns nil if is not correct type") {
                    expect(SupportedType.number(bool: true, int: 1).double).to(beNil())
                    
                    expect(SupportedType.number(bool: true, double: 1.1).int).to(beNil())
                    
                    expect(SupportedType.number(int: 1, double: 1.1).bool).to(beNil())
                    
                    expect(SupportedType.number(bool: true, int: 1, double: 1.1).string).to(beNil())
                }
                it("returns number if is number") {
                    expect(SupportedType.number(bool: true, int: 1).number?.bool).to(beTrue())
                    expect(SupportedType.number(bool: true, int: 1).number?.int) == 1
                    
                    expect(SupportedType.number(bool: true, double: 1.1).number?.bool).to(beTrue())
                    expect(SupportedType.number(bool: true, double: 1.1).number?.double) == 1.1
                    
                    expect(SupportedType.number(int: 1, double: 1.1).number?.int) == 1
                    expect(SupportedType.number(int: 1, double: 1.1).number?.double) == 1.1
                    
                    expect(SupportedType.number(bool: true, int: 1, double: 1.1).number?.bool).to(beTrue())
                    expect(SupportedType.number(bool: true, int: 1, double: 1.1).number?.int) == 1
                    expect(SupportedType.number(bool: true, int: 1, double: 1.1).number?.double) == 1.1
                }
                it("returns nil if is not number") {
                    expect(SupportedType.number(bool: true, int: 1).number?.double).to(beNil())
                    
                    expect(SupportedType.number(bool: true, double: 1.1).number?.int).to(beNil())
                    
                    expect(SupportedType.number(int: 1, double: 1.1).number?.bool).to(beNil())
                    
                    expect(SupportedType.number(bool: true, int: 1, double: 1.1).string).to(beNil())
                }
            }
            describe("addToDictionary") {
                it("adds value to dictionary") {
                    let type: SupportedType = .dictionary(["a": .bool(true)])
                    
                    type.addToDictionary(key: "b", value: .bool(false))
                    
                    expect(type) == SupportedType.dictionary(["a": .bool(true), "b": .bool(false)])
                }
                it("creates new dictionary if necessary") {
                    let type: SupportedType = .bool(true)
                    
                    type.addToDictionary(key: "b", value: .bool(false))
                    
                    expect(type) == SupportedType.dictionary(["b": .bool(false)])
                }
            }
        }
    }
}
