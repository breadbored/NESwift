//
//  BaseInstructions.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/12.
//

import Foundation

class Jmp: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.pc_reg = memory_address!
    }
    
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Jsr: Jmp {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.set_stack_value(value: NESMemValue(uint16: cpu.pc_reg - 1), num_bytes: 2)
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address, value: value)
    }
}

class Rts: Jmp {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let old_pc_reg = cpu.get_stack_value(num_bytes: Numbers.SHORT.rawValue).uint16 + 1
        return super.write(addr: addr, cpu: cpu, memory_address: old_pc_reg, value: value)
    }
}

class Brk: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.pc_reg += 1
        cpu.set_stack_value(value: NESMemValue(uint16: cpu.pc_reg), num_bytes: Numbers.SHORT.rawValue)
        let status = cpu.status_reg!.to_int()
        cpu.set_stack_value(value: NESMemValue(uint8: status), num_bytes: Numbers.BYTE.rawValue)
        cpu.status_reg?.bits[Status.StatusType.INTERRUPT.rawValue].1 = true
        return nil
    }
    
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Rti: Jmp {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let status = cpu.get_stack_value(num_bytes: Numbers.BYTE.rawValue)
        cpu.status_reg?.from_int(value: status, bits_to_ignore: [4, 5])
        let old_pc_reg = cpu.get_stack_value(num_bytes: Numbers.SHORT.rawValue)
        return super.write(addr: addr, cpu: cpu, memory_address: old_pc_reg.uint16, value: value)
    }
}

class BranchClear: Jmp, HasRelativeAddressing {
    var relative_addressing: RelativeAddressing = RelativeAddressing()
    var data_length: UInt8 {
        get {
            return relative_addressing.data_length
        }
        set {
            relative_addressing.data_length = newValue
        }
    }
    var get_address: (Addressing, CPU, [UInt8]) -> UInt16
    
    override init() {
        self.get_address = self.relative_addressing.get_address
        super.init()
    }
    
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        if !(cpu.status_reg!.bits[addr.bit.rawValue].1) {
            return super.write(addr: addr, cpu: cpu, memory_address: memory_address, value: value)
        }
    }
}

class BranchSet: Jmp, HasRelativeAddressing {
    var relative_addressing: RelativeAddressing = RelativeAddressing()
    var data_length: UInt8 {
        get {
            return relative_addressing.data_length
        }
        set {
            relative_addressing.data_length = newValue
        }
    }
    var get_address: (Addressing, CPU, [UInt8]) -> UInt16
    
    override init() {
        self.get_address = self.relative_addressing.get_address
        super.init()
    }
    
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        if cpu.status_reg!.bits[addr.bit.rawValue].1 {
            return super.write(addr: addr, cpu: cpu, memory_address: memory_address, value: value)
        }
    }
}

class Nop: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        return nil
    }
}

class Bit: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_overflow_bit_from_value = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.status_reg?.bits[Status.StatusType.ZERO.rawValue].1 = (value.uint8 & cpu.a_reg) == 0x0
    }
    
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Ld: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        return nil
    }
    
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Lda: Ld {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.a_reg = value.uint8
        return NESMemValue(uint8: cpu.a_reg)
    }
}

class Ldx: Ld {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        Lda().write(addr: addr, cpu: cpu, memory_address: memory_address, value: value)
        return Tax().write(addr: addr, cpu: cpu, memory_address: memory_address, value: value)
    }
}

class Ldy: Ld {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.y_reg = value.uint8
    }
}

class Sta: WritesToMem, Instruction {
    var instructionValues: InstructionValues = InstructionValues()
    
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: cpu.a_reg)
    }
}

class Sax: WritesToMem, Instruction {
    var instructionValues: InstructionValues = InstructionValues()
    
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: cpu.a_reg & cpu.x_reg)
    }
}

class Stx: WritesToMem, Instruction {
    var instructionValues: InstructionValues = InstructionValues()
    
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: cpu.x_reg)
    }
}

class Sty: WritesToMem, Instruction {
    var instructionValues: InstructionValues = InstructionValues()
    
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: cpu.y_reg)
    }
}

class And: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.a_reg &= value.uint8
        return NESMemValue(uint8: cpu.a_reg)
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Ora: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.a_reg |= value.uint8
        return NESMemValue(uint8: cpu.a_reg)
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Eor: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.a_reg ^= value.uint8
        return NESMemValue(uint8: cpu.a_reg)
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Adc: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let result: UInt8 = cpu.a_reg + value.uint8 + (cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 ? 1 : 0)
        let overflow: Bool = ((cpu.a_reg ^ result) & (value.uint8 ^ result) & 0x80) != 0x00
        cpu.status_reg!.bits[Status.StatusType.OVERFLOW.rawValue].1 = overflow
        cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 = (result & 0xff) != 0x00
        return NESMemValue(uint8: cpu.a_reg)
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Sbc: Adc {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address, value: NESMemValue(uint8: value.uint8 ^ 0xFF))
    }
}

class Shift: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        guard let mem_addr = memory_address else {
            cpu.a_reg = value.uint8
            return value
        }
        try! cpu.set_memory(location: mem_addr, value: value, num_bytes: Numbers.BYTE.rawValue)
        return value
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Lsr: Shift {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let updatedValue = value.uint8 >> 1
        cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 = (value.uint8 & 0b1) != 0x00
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address!, value: NESMemValue(uint8: updatedValue))
    }
}

class Asl: Shift {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let updateWithout7 = value.uint8 & 0b01111111
        let updatedValue = updateWithout7 << 1
        let originalBit7 = (value.uint8 & 0b10000000) >> 7
        cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 = originalBit7 != 0x00
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address!, value: NESMemValue(uint8: updatedValue))
    }
}

class Roe: Shift {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let shiftedWithout7 = value.uint8 >> 1
        let shiftedCarry = UInt8(cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 ? 1 : 0) << 7
        let updatedValue = shiftedWithout7 | shiftedCarry
        cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 = (value.uint8 & 0b1) != 0x00
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address!, value: NESMemValue(uint8: updatedValue))
    }
}

class Rol: Shift {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let valueRegWithout7 = value.uint8 & 0b01111111
        let shiftedWithout0 = valueRegWithout7 << 1
        let shiftedCarry: UInt8 = cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 ? 1 : 0
        let updatedValue = shiftedWithout0 | shiftedCarry
        let originalBit7 = (value.uint8 & 0b10000000) >> 7
        cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 = originalBit7 != 0x00
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address!, value: NESMemValue(uint8: updatedValue))
    }
}

class Inc: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let originalValue = try! cpu.get_memory(location: memory_address!, num_bytes: Numbers.BYTE.rawValue)
        let updatedValue = NESMemValue(uint8: originalValue.uint8 + 1)
        try! cpu.set_memory(location: memory_address!, value: updatedValue, num_bytes: Numbers.BYTE.rawValue)
        return updatedValue
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Dec: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let originalValue = try! cpu.get_memory(location: memory_address!, num_bytes: Numbers.BYTE.rawValue)
        let updatedValue = NESMemValue(uint8: originalValue.uint8 - 1)
        try! cpu.set_memory(location: memory_address!, value: updatedValue, num_bytes: Numbers.BYTE.rawValue)
        return updatedValue
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Compare: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        cpu.status_reg!.bits[Status.StatusType.CARRY.rawValue].1 = value.uint8 & 0xff == 0x00
        return value
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Cmp: Compare {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let result = cpu.a_reg - value.uint8
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address!, value: NESMemValue(uint8: result))
    }
}

class Dcp: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let updatedValue = Dec().write(addr: addr, cpu: cpu, memory_address: memory_address!, value: value)
        return Cmp().write(addr: addr, cpu: cpu, memory_address: memory_address!, value: updatedValue!)
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Isb: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let updatedValue = Inc().write(addr: addr, cpu: cpu, memory_address: memory_address!, value: value)
        return Sbc().write(addr: addr, cpu: cpu, memory_address: memory_address!, value: updatedValue!)
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class Cpx: Compare {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let result = cpu.x_reg - value.uint8
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address!, value: NESMemValue(uint8: result))
    }
}

class Cpy: Compare {
    override func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let result = cpu.y_reg - value.uint8
        return super.write(addr: addr, cpu: cpu, memory_address: memory_address!, value: NESMemValue(uint8: result))
    }
}

class StackPush: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let dataToPush = addr.data_to_push(addr: addr, cpu: cpu)
        cpu.set_stack_value(value: dataToPush, num_bytes: Numbers.BYTE.rawValue)
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}

class StackPull: Instruction {
    var instructionValues: InstructionValues = InstructionValues()
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
    
    init() {
        self.sets_negative_bit = true
        self.sets_zero_bit = true
    }
    
    func write(addr: Addressing, cpu: CPU, memory_address: UInt16?, value: NESMemValue) -> NESMemValue? {
        let pulledData = cpu.get_stack_value(num_bytes: Numbers.BYTE.rawValue)
        return addr.write_pulled_data(cpu: cpu, value: pulledData)
    }
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
    func get_data(addr: Addressing, cpu: CPU, memory_address: UInt16?, data_bytes: [UInt8]) -> NESMemValue {
        return NESMemValue(uint8: 0)
    }
}
