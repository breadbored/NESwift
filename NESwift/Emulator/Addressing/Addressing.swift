//
//  Base.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/07.
//

import Foundation

/**
 Base protocol for addressing. Not to be used directly.
 */
protocol Addressing {
    var data_length: UInt16 { get set }
    var bit: Status.StatusType { get set }
    
    func get_instruction_length(addr: Addressing) -> UInt16
    func data_to_push(cpu: CPU) -> NESMemValue
    func write_pulled_data(cpu: CPU, value: NESMemValue) -> NESMemValue
    func get_offset(addr: Addressing, cpu: CPU) -> UInt16
}
extension Addressing {
    func get_instruction_length(addr: Addressing) -> UInt16 {
        return addr.data_length + 1
    }
    func data_to_push(cpu: CPU) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
    func write_pulled_data(cpu: CPU, value: NESMemValue) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
    func get_offset(addr: Addressing, cpu: CPU) -> UInt16 {
        return 0
    }
}

/**
 Base protocol for x reg offset. Not to be used directly.
 */
protocol XRegisterOffset {
    func get_offset(addr: Addressing, cpu: CPU) -> UInt8
}
extension XRegisterOffset {
    func get_offset(addr: Addressing, cpu: CPU) -> UInt8 {
        return cpu.x_reg
    }
}

/**
 Base protocol for y reg offset. Not to be used directly.
 */
protocol YRegisterOffset {
    func get_offset(addr: Addressing, cpu: CPU) -> UInt8
}
extension YRegisterOffset {
    func get_offset(addr: Addressing, cpu: CPU) -> UInt8 {
        return cpu.y_reg
    }
}

/**
 Instructions with data passed
 */
class ImpliedAddressing: Addressing {
    var data_length: UInt16
    
    init() {
        self.data_length = 0
    }
}

/**
 Get value from accumulator
 */
class AccumulatorAddressing: Addressing {
    var data_length: UInt16
    
    init() {
        self.data_length = 0
    }
    
    func get_data(addr: Addressing, cpu: CPU, mem_addr: UInt16, data_bytes: [UInt8]) -> UInt8 {
        return cpu.a_reg
    }
}

/**
 Read value from instruction data
 asm example: STA #9
 */
class ImmediateReadAddressing: Addressing {
    var data_length: UInt16
    
    init() {
        self.data_length = 1
    }
    
    func get_data(addr: Addressing, cpu: CPU, mem_addr: UInt16, data_bytes: [UInt8]) -> UInt8 {
        return data_bytes.first!
    }
}

/**
 Lookup value from memory address
 */
class AbsoluteAddressing: Addressing {
    var data_length: UInt16
    
    init() {
        self.data_length = 2
    }
    
    func get_address(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt16? {
        let u16: UInt16 = data_bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
        return u16 + addr.get_offset(addr: addr, cpu: cpu)
    }
}

/**
 Adds X Reg offset to absolute memory location
 */
class AbsoluteAddressingWithX: AbsoluteAddressing, XRegisterOffset {
    
}

/**
 Adds Y Reg offset to absolute memory location
 */
class AbsoluteAddressingWithY: AbsoluteAddressing, YRegisterOffset {
    
}

/**
 Look up an absolute memory address in the first 256 bytes
 */
class ZeroPageAddressing: AbsoluteAddressing {
    override init() {
        super.init()
        self.data_length = 1
    }
}

/**
 Adds the x reg offset to an absolute memory address in the first 256 bytes
 */
class ZeroPageAddressingWithX: ZeroPageAddressing, XRegisterOffset {
    
}

/**
 Adds the y reg offset to an absolute memory address in the first 256 bytes
 */
class ZeroPageAddressingWithY: ZeroPageAddressing, YRegisterOffset {
    
}

/**
 Offset from current PC, can only jump 128 bytes in either direction
 */
class RelativeAddressing: Addressing {
    var data_length: UInt8 = 1
    
    func get_address(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt16 {
        let current_address: UInt16 = cpu.pc_reg
        
        let data_bytes: UInt16 = data_bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
        return data_bytes + current_address
    }
}
protocol HasRelativeAddressing {
    var relative_addressing: RelativeAddressing { get set }
}

/**
 Offset from current PC, can only jump 128 bytes in either direction
 */
class IndirectAddressing: AbsoluteAddressing {
    override func get_address(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt16? {
        let lsb_location: UInt16 = super.get_address(addr: addr, cpu: cpu, data_bytes: data_bytes)!
        var msb_location: UInt16 = lsb_location + 0x01
        
        if msb_location % 0x100 == 0x00 {
            msb_location = lsb_location - 0xFF
        }
        
        let mem = cpu.get_memory(lsb_location, num_bytes: Numbers.SHORT.rawValue)
        return mem.uint16
    }
}

/**
 Offset from current PC, can only jump 128 bytes in either direction
 */
class IndirectAddressingithX: ZeroPageAddressingWithX {
    override func get_address(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt16? {
        let lsb_location: UInt16 = super.get_address(addr: addr, cpu: cpu, data_bytes: data_bytes)!
        var msb_location: UInt16 = lsb_location + 0x01
        
        if msb_location % 0x100 == 0x00 {
            msb_location = lsb_location - 0xFF
        }
        
        return cpu.get_memory(lsb_location, num_bytes: Numbers.SHORT.rawValue).uint16
    }
}

/**
 Offset from current PC, can only jump 128 bytes in either direction
 */
class IndirectAddressingithY: ZeroPageAddressingWithY {
    override func get_address(addr: Addressing, cpu: CPU, data_bytes: [UInt8]) -> UInt16? {
        let get_addr: UInt16 = super.get_address(addr: addr, cpu: cpu, data_bytes: data_bytes)!
        return get_addr + UInt16(cpu.y_reg)
    }
}
