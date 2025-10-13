//
//  CryptKeeperApp.swift
//  CryptKeeper
//
//  Created by Oliphant, Corey Dean on 10/6/25.
//

import SwiftUI

@main
struct CryptKeeperApp: App {
    init() {
        UserDefaults.standard.set(100, forKey: "NSInitialToolTipDelay")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 450)
        }
    }
}
