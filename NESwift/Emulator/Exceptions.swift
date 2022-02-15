//
//  Exceptions.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/09.
//

import Foundation

class NESSwiftError: Error {
    var message: String = "Memory Owner could not be found"
    
    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
