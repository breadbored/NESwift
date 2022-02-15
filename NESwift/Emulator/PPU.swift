//
//  PPU.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/09.
//

import Foundation

class PPU: MemoryOwner {
    var memory_start_location: UInt16 = 0x2000
    var memory_end_location: UInt16   = 0x2007
    var memory = [UInt8](repeating: 0x0, count: 8)
    
    func get_memory() -> [UInt8] {
        return self.memory
    }
    
    func set_memory(position: UInt16, value: UInt8) throws {
        self.memory[Int(position)] = value
    }
    
    func set(position: UInt16, value: NESMemValue, size: UInt8) throws {
        if size == Numbers.BYTE.rawValue {
            try self.set_memory(
                position: position - self.memory_start_location,
                value: value.uint8
            )
        }
        if size == Numbers.SHORT.rawValue {
            let upper: UInt8 = self.get_memory()[Int(position - self.memory_start_location)]
            let lower: UInt8 = self.get_memory()[Int(position - self.memory_start_location - 1)]
            
            try self.set_memory(
                position: position - self.memory_start_location,
                value: upper
            )
            try self.set_memory(
                position: position - self.memory_start_location - 1,
                value: lower
            )
        }
        throw NESSwiftError("Cannot get bytes from memory")
    }
}
