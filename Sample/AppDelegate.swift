//
//  AppDelegate.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = UIWindow()
    lazy var appRouter = AppRouter()

    private var observers: [UIApplicationDelegate]? = [
        WindowCustomizer(),
        GoogleSignInDelegate(),
        AppRouter()
    ]

    static var shared: AppDelegate {
        guard let `self` = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return self
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpAppWindow()
        observers?.forEach {
            _ = $0.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        observers?.forEach {
            _ = $0.application?(application, open: url, options: options)
        }
        return true
    }
}

// MARK: - Set up the window

extension AppDelegate {
    private func setUpAppWindow() {
        window?.frame = UIScreen.main.bounds
        window?.makeKeyAndVisible()
    }
}
