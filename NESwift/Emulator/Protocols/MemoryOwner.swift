//
//  MemoryOwner.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/09.
//

import Foundation

/// Reference
/// https://github.com/PyAndy/Py3NES/blob/38926e1397b4a894422ce3460f760873e40d6c04/memory_owner.py#L7
protocol MemoryOwner {
    var memory_start_location: UInt16 { get set }
    var memory_end_location: UInt16 { get set }
    func get_memory() -> [UInt8]
    func set_memory(position: UInt16, value: UInt8) throws
    func get(position: UInt16, size: UInt8) throws -> NESMemValue
    func set(position: UInt16, value: NESMemValue, size: UInt8) throws
}
extension MemoryOwner {
    var memory_start_location: UInt16 {
        get {
            return self.memory_start_location
        }
        set(mem_start) {
            self.memory_start_location = mem_start
        }
    }
    var memory_end_location: UInt16 {
        get {
            return self.memory_end_location
        }
        set(mem_end) {
            self.memory_end_location = mem_end
        }
    }
    
    func get(position: UInt16, size: UInt8) throws -> NESMemValue {
        if size == Numbers.BYTE.rawValue {
            return NESMemValue(uint8: self.get_memory()[Int(position - self.memory_start_location)])
        }
        if size == Numbers.SHORT.rawValue {
            let upper: UInt8 = self.get_memory()[Int(position - self.memory_start_location)]
            let lower: UInt8 = self.get_memory()[Int(position - self.memory_start_location - 1)]
            return NESMemValue(uint16: [upper, lower].withUnsafeBytes { $0.load(as: UInt16.self) })
        }
        throw NESSwiftError("Cannot get bytes from memory")
    }
}
