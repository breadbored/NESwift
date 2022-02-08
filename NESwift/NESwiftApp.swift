//
//  NESwiftApp.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/07.
//

import SwiftUI

@main
struct NESwiftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
