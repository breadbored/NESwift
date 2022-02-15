//
//  ROM.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/09.
//

import Foundation

class ROM {
    var memory_start_location: UInt16 = 0x8000
    var memory_end_location: UInt16   = 0xFFFF
    var memory = [UInt8](repeating: 0x0, count: 0x20)
    var header_size: UInt8 = 0x10
    var num_prg_blocks: UInt8 = 2
    var rom_bytes: [UInt8]
    var prg_bytes: [UInt8]
    
    init(rom_bytes: [UInt8]) {
        self.rom_bytes = rom_bytes
        self.prg_bytes = Array(
            rom_bytes[
                Int(self.header_size)...(Int(self.header_size) + (16 * KB * Int(self.num_prg_blocks)))]
        )
    }
    
    func get_memory() -> [UInt8] {
        return self.memory
    }
    
    func set_memory(position: UInt16, value: NESMemValue) {
        self.memory[Int(position)] = value.uint8
    }
    
    func get(position: UInt16, size: UInt8) throws -> [UInt8] {
        var pos = position
        if pos > 0xC000 {
            pos = 0x4000
        }
        return Array(
            self.get_memory()[Int(pos - self.memory_start_location)...Int(pos - UInt16(self.memory_start_location) + UInt16(size))]
        )
    }
    
    func set(position: UInt16, value: NESMemValue, size: UInt8) throws {
        throw NESSwiftError("Cannot write to ROM")
    }
}
