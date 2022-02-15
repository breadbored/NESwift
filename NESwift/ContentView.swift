//
//  ContentView.swift
//  NESwift
//
//  Created by Jason Carpenter on 2022/02/07.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Text("NES").frame(width: 100.0, height: 100.0, alignment: .center).onAppear {
            test()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
