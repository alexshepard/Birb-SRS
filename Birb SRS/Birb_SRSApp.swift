//
//  Birb_SRSApp.swift
//  Birb SRS
//
//  Created by Alex Shepard on 3/24/24.
//

import SwiftUI

@main
struct Birb_SRSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Taxon.self)
    }
}
