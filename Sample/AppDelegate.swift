//
//  AppDelegate.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import UIKit
import YTLiveStreaming

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var googleSignIn = GoogleSignInInteractor()
    var appRouter = AppRouter()

    static var shared: AppDelegate {
        guard let `self` = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return self
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Appearance.customize()
        setUpWindow()
        appRouter.showSignInViewController()
        return true
    }

    private func setUpWindow() {
        window = UIWindow()
        window!.frame = UIScreen.main.bounds
        window!.makeKeyAndVisible()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return googleSignIn.openURL(url)
    }

    /**
     Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
     or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates
     Games should use this method to pause the game.
     */
    func applicationWillResignActive(_ application: UIApplication) {
    }

    /**
     Use this method to release shared resources, save user data, invalidate timers,
     and store enough application state information to restore your application to
     its current state in case it is terminated later.
     If your application supports background execution, this method is called instead
     of applicationWillTerminate: when the user quits.
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    /**
      Called as part of the transition from the background to the inactive state;
     here you can undo many of the changes made on entering the background.
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    /**
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     If the application was previously in the background, optionally refresh the user interface.
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    /**
    Called when the application is about to terminate. Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    func applicationWillTerminate(_ application: UIApplication) {
    }
}
