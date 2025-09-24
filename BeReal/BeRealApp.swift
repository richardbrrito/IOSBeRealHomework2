//
//  BeRealApp.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import SwiftUI
import ParseSwift

@main
struct BeRealApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
