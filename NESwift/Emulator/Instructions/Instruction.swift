//
//  Instruction.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/12.
//

import Foundation

struct InstructionValues {
    var identifier_byte: [UInt8]? = nil
    var sets_zero_bit: Bool = false
    var sets_negative_bit: Bool = false
    var sets_overflow_bit_from_value: Bool = false
    var data_length: UInt8 = 0x0
}

protocol HasInstructionValues {
    var instructionValues: InstructionValues { get set }
}

protocol Instruction: HasInstructionValues {
    func get_address(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt16?
    func apply_side_effects(addr: Addressing, cpu: CPU)
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue?
    func execute(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt8
    func get_instruction_length() -> UInt8
}
extension Instruction {
    var identifier_byte: [UInt8]? {
        get { return instructionValues.identifier_byte }
        set { instructionValues.identifier_byte = newValue }
    }
    var sets_zero_bit: Bool {
        get { return instructionValues.sets_zero_bit }
        set { instructionValues.sets_zero_bit = newValue }
    }
    var sets_negative_bit: Bool {
        get { return instructionValues.sets_negative_bit }
        set { instructionValues.sets_negative_bit = newValue }
    }
    var sets_overflow_bit_from_value: Bool {
        get { return instructionValues.sets_overflow_bit_from_value }
        set { instructionValues.sets_overflow_bit_from_value = newValue }
    }
    var data_length: UInt8 {
        get { return instructionValues.data_length }
        set { instructionValues.data_length = newValue }
    }
    
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return cpu.get_memory(memory_address!, num_bytes: 1)
    }
}

class WritesToMem {
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        try! cpu.set_memory(location: memory_address!, value: value, num_bytes: 1)
        return nil
    }
    // Force override on child class
    func get_address(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt16? {
        return nil
    }
    func apply_side_effects(addr: Addressing, cpu: CPU) {
        return
    }
    func execute(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt8 {
        return 0
    }
    func get_instruction_length() -> UInt8 {
        return 0
    }
}
