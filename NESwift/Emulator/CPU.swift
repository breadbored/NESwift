//
//  CPU.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/07.
//

import Foundation

class CPU {
    var loadedData: [UInt8] = []
    var cpuAddress: UInt = 0
    
    var a_reg: UInt8 = 0x00
    var x_reg: UInt8 = 0x00
    var y_reg: UInt8 = 0x00
    var sp_reg: UInt16 = 0x0000
    var pc_reg: UInt16 = 0x0000
    var status_reg: Status? = nil
    
    var stack_offset: UInt16 = 0x0100
    
    var running: Bool = true
    
    var c_flag: Bool = false
    var z_flag: Bool = false
    var i_flag: Bool = false
    var d_flag: Bool = false
    var b_flag: Bool = false
    var v_flag: Bool = false
    var n_flag: Bool = false
    
    var instruction: Instruction? = nil
    var data_bytes: [UInt8]? = nil
    var instruction_byte: UInt8? = nil
    
    var ram: RAM
    var ppu: PPU
    var apu: APU
    var rom: ROM? = nil
    
    var memory_owners: [AnyObject] = []
    
    init(ram: RAM, ppu: PPU, apu: APU) {
        self.ram = ram
        self.ppu = ppu
        self.apu = apu
        
        memory_owners = [
            self.ram,
            self.ppu,
            self.apu,
        ]
    }
    
    /**
     Return a byte from a given memory location
     */
    func get_memory(_ mem_location: UInt16, num_bytes: UInt8) -> NESMemValue {
        let mem_owner: MemoryOwner = try! self._get_memory_owner(mem_location)
        return try! mem_owner.get(position: mem_location, size: num_bytes)
    }
    
    func start_up() {
        self.pc_reg = 0x0000
        self.status_reg = Status()
        self.sp_reg = 0xFD
        self.x_reg = 0x0
        self.y_reg = 0x0
        self.a_reg = 0x0
    }
    
    /**
     Return the owner of a memory location
     */
    func _get_memory_owner(_ mem_location: UInt16) throws -> MemoryOwner {
        for mem_owner in self.memory_owners {
            if let mo = mem_owner as? MemoryOwner {
                if mo.memory_start_location <= mem_location,
                   mem_location <= mo.memory_end_location {
                    if let owner = mo as? RAM {
                        return owner
                    } else if let owner = mo as? PPU {
                        return owner
                    } else if let owner = mo as? APU {
                        return owner
                    }
                }
            }
        }
        
        throw NESSwiftError("Memory owner not found")
    }
    
    func get_memory(location: UInt16, num_bytes: UInt8) throws -> NESMemValue {
        for owner in self.memory_owners {
            if let owner = owner as? RAM {
                if owner.memory_start_location <= location,
                   location <= owner.memory_end_location {
                    return try! owner.get(position: location, size: num_bytes)
                }
            } else if let owner = owner as? PPU {
                if owner.memory_start_location <= location,
                   location <= owner.memory_end_location {
                    return try! owner.get(position: location, size: num_bytes)
                }
            } else if let owner = owner as? APU {
                if owner.memory_start_location <= location,
                   location <= owner.memory_end_location {
                    return try! owner.get(position: location, size: num_bytes)
                }
            }
        }
        throw NESSwiftError("Cannot get memory from memory owner")
    }
    
    func set_memory(location: UInt16, value: NESMemValue, num_bytes: UInt8) throws {
        for owner in self.memory_owners {
            if let owner = owner as? RAM {
                if owner.memory_start_location <= location,
                   location <= owner.memory_end_location {
                    try! owner.set(position: location, value: value, size: num_bytes)
                }
            } else if let owner = owner as? PPU {
                if owner.memory_start_location <= location,
                   location <= owner.memory_end_location {
                    try! owner.set(position: location, value: value, size: num_bytes)
                }
            } else if let owner = owner as? APU {
                if owner.memory_start_location <= location,
                   location <= owner.memory_end_location {
                    try! owner.set(position: location, value: value, size: num_bytes)
                }
            }
        }
        throw NESSwiftError("Cannot set memory in memory owner")
    }
    
    func set_stack_value(value: NESMemValue, num_bytes: UInt8) {
        try! self.set_memory(
            location: self.stack_offset + self.sp_reg,
            value: value,
            num_bytes: num_bytes
        )
        
        self.sp_reg -= UInt16(num_bytes)
    }
    
    func get_stack_value(num_bytes: UInt8) -> NESMemValue {
        self.sp_reg += UInt16(num_bytes)
        
        return try! self.get_memory(
            location: self.stack_offset + self.sp_reg,
            num_bytes: num_bytes
        )
    }
    
    func load_rom(rom: ROM) {
        if self.rom != nil {
            var index = 0
            for x in self.memory_owners {
                if let _ = x as? ROM {
                    self.memory_owners.remove(at: index)
                }
                index += 1
            }
        }
        self.rom = rom
        self.memory_owners.append(self.rom as AnyObject)
        self.pc_reg = self.get_memory(0xFFFC, num_bytes: 2).uint16
    }
    
    func execute() {
        self.pc_reg += UInt16(self.instruction!.get_instruction_length())
        let value: NESMemValue = NESMemValue(uint8: self.instruction!.execute(cls: self.instruction as! Addressing, cpu: self, data_bytes: self.data_bytes!))
        self.status_reg!.update(self.instruction!, value: value)
    }
    
    func readRomFromFile(filename: String) -> [UInt8] {
        if let fileURL = Bundle.main.path(forResource: filename, ofType: "nes") {
            let fURL: URL = URL(fileURLWithPath: fileURL)
            do {
                let contents = try Data(contentsOf: fURL)
                return [UInt8](contents)
            } catch {
                return []
            }
        }
        return []
    }
    
    
}
