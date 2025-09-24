//
//  AppDelegate.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import UIKit
import ParseSwift

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        ParseSwift.initialize(
            applicationId: "Fnsb4n7YgmRVp3Y6m27RHNIjPWsW77OhhxZWnM1y",
            clientKey: "c7N10nKdAUjfgXFYZ5qmmfiUWVnSNRP4PaNWlkZQ",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
        
        return true
    }
}


var emailVerified: Bool?
