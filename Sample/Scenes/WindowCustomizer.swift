//
//  WindowCustomizer.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 6/13/22.
//

import UIKit

class WindowCustomizer: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Appearance.shared.customize.window()
        Appearance.shared.customize.navigationBar()
        Appearance.shared.customize.statusBar()
        return true
    }
}
