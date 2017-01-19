//
//  SupportedNumberTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 30.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class SupportedNumberTest: QuickSpec {
    
    override func spec() {
        describe("SupportedNumber") {
            describe("init") {
                it("initializes object") {
                    let none = SupportedNumber()
                    let bool = SupportedNumber(bool: true)
                    let int = SupportedNumber(int: 1)
                    let double = SupportedNumber(double: 1.1)
                    let all = SupportedNumber(bool: false, int: 0, double: 0)
                    
                    expect(none.bool).to(beNil())
                    expect(none.int).to(beNil())
                    expect(none.double).to(beNil())
                    
                    expect(bool.bool) == true
                    expect(bool.int).to(beNil())
                    expect(bool.double).to(beNil())
                    
                    expect(int.bool).to(beNil())
                    expect(int.int) == 1
                    expect(int.double).to(beNil())
                    
                    expect(double.bool).to(beNil())
                    expect(double.int).to(beNil())
                    expect(double.double) == 1.1
                    
                    expect(all.bool) == false
                    expect(all.int) == 0
                    expect(all.double) == 0
                }
            }
            describe("==") {
                it("returns true if bool, int and double are equal") {
                    expect(SupportedNumber(bool: true)) == SupportedNumber(bool: true)
                    expect(SupportedNumber(int: 1)) == SupportedNumber(int: 1)
                    expect(SupportedNumber(double: 2)) == SupportedNumber(double: 2)
                    expect(SupportedNumber(int: 1, double: 2)) == SupportedNumber(int: 1, double: 2)
                    expect(SupportedNumber(bool: true, int: 1)) == SupportedNumber(bool: true, int: 1)
                    expect(SupportedNumber(bool: true, double: 2)) == SupportedNumber(bool: true, double: 2)
                    expect(SupportedNumber(bool: true, int: 1, double: 2)) == SupportedNumber(bool: true, int: 1, double: 2)
                }
                it("returns false if int and double are not equal") {
                    expect(SupportedNumber(int: 1)) != SupportedNumber(int: 2)
                    expect(SupportedNumber(bool: true)) != SupportedNumber(int: 2)
                    expect(SupportedNumber(int: 1)) != SupportedNumber(double: 2)
                    expect(SupportedNumber(int: 1)) != SupportedNumber(int: 1, double: 2)
                    expect(SupportedNumber(int: 1, double: 2)) != SupportedNumber(int: 2, double: 2)
                    expect(SupportedNumber(bool: false, int: 1, double: 2)) != SupportedNumber(bool: true, int: 1, double: 2)
                }
            }
        }
    }
}
