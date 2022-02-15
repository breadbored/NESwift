//
//  Constants.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/12.
//

import Foundation

let KB = 1024

// Not constants, but I didn't know where to put this lol

/// Raise an Int to the power of another Int
precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

/// Give UInt16 a property to return an array of UInt8
extension UInt16 {
    var uint8: [UInt8] {
        let source = self
        return withUnsafeBytes(of: source) { Array($0) }
    }
}

/// Give UInt8 a property to return a UInt16
extension Sequence where Iterator.Element == UInt8 {
    var uint16: UInt16 {
        let source: [UInt8] = [UInt8](self)
        return source.withUnsafeBytes { $0.load(as: UInt16.self) }
    }
}

class NESMemValue {
    var uint8: UInt8
    var uint8s: [UInt8]
    var uint16: UInt16
    
    init(uint8: UInt8) {
        self.uint8 = uint8
        self.uint8s = [0x0, uint8]
        self.uint16 = self.uint8s.uint16
    }
    
    init(uint8s: [UInt8]) {
        self.uint8 = uint8s[1]
        self.uint8s = uint8s
        self.uint16 = self.uint8s.uint16
    }
    
    init(uint16: UInt16) {
        self.uint8s = uint16.uint8
        self.uint16 = uint16
        self.uint8 = self.uint8s[1]
    }
}
