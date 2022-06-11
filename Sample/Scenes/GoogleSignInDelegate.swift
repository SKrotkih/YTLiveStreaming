//
//  GoogleSignInDelegate.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 6/13/22.
//

import UIKit
import GoogleSignIn

class GoogleSignInDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // source from https://developers.google.com/identity/sign-in/ios/sign-in#3_attempt_to_restore_the_users_sign-in_state

        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                Router.showSignInViewController()
            } else {
                // Show the app's signed-in state.
                Router.showMainViewController()
            }
        }
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {

        // source from https://developers.google.com/identity/sign-in/ios/sign-in#ios_uiapplicationdelegate

        var handled: Bool

        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }

        // Handle other custom URL types.

        // If not handled by this app, return false.
        return false
    }
}
