//
//  Status.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/12.
//

import Foundation

class Status {
    enum StatusType: Int {
        case CARRY = 0
        case ZERO = 1
        case INTERRUPT = 2
        case DECIMAL = 3
        case UNUSED1 = 4
        case UNUSED2 = 5
        case OVERFLOW = 6
        case NEGATIVE = 7
    }
    
    var bits: [(StatusType, Bool)] = [
        (StatusType.CARRY, false),
        (StatusType.ZERO, false),
        (StatusType.INTERRUPT, false),
        (StatusType.DECIMAL, false),
        (StatusType.UNUSED1, false),
        (StatusType.UNUSED2, false),
        (StatusType.OVERFLOW, false),
        (StatusType.NEGATIVE, false),
    ]
    func get_bit_index(status_type: StatusType) throws -> Int {
        var index = 0
        for x in self.bits {
            if x.0 == status_type {
                return index
            }
            index += 1
        }
        throw NESSwiftError("Could not update status")
    }
    
    func update(_ instruction: Instruction, value: NESMemValue) {
        if instruction.sets_zero_bit {
            self.bits[StatusType.ZERO.rawValue].1 = value.uint8 == 0x0
        }
        if instruction.sets_negative_bit {
            self.bits[StatusType.NEGATIVE.rawValue].1 = (value.uint8 & 0b10000000) != 0x0
        }
        if instruction.sets_overflow_bit_from_value {
            self.bits[StatusType.OVERFLOW.rawValue].1 = (value.uint8 & 0b01000000) != 0x0
        }
    }
    
    func to_int() -> UInt8 {
        var value: UInt = 0x0
        for bit in self.bits {
            value += (bit.1 ? 1 : 0) * UInt(2 ^^ bit.0.rawValue)
        }
        return UInt8(value)
    }
    
    func from_int(value: NESMemValue, bits_to_ignore: [UInt8]) {
        for (i, _) in self.bits.enumerated() {
            if bits_to_ignore.contains(UInt8(i)) {
                continue
            }
            self.bits[i].1 = (value.uint8 & (1 << i)) != 0
        }
    }
}
