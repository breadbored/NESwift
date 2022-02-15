//
//  MainEmulator.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/07.
//

import Foundation

func test() {
    let cpu: CPU = CPU()
    let game: [UInt8] = cpu.readRomFromFile(filename: "nestest")
    cpu.loadedData = game
    
    for var addr in 0..<game.count {
        print("ADDR 0x\(String(format:"%04X", addr)) 0x\(String(format:"%02X", game[addr])) OPCODE")
        addr += cpu.readOpcode(addr: UInt16(addr), opcode: game[addr])
    }
}
