//  Appearance
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

class Appearance {

    private init() {}

    static let shared = Appearance()

    private let customizeStatusBarNeeded = false

    var statusBarStyle: UIStatusBarStyle {
        return customizeStatusBarNeeded ? .default : .lightContent
    }

    var customize: Appearance {
        return self
    }

    // MARK: - Customize View Components

    func window() {
        // Color file template should be added into the project.
        UIApplication.shared.keyWindow?.tintColor = .black
    }

    func navigationBar() {
        let navBar = UINavigationBar.appearance()

        navBar.tintColor = .white

        // Navigation bar title
        let attr: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)
        ]
        navBar.titleTextAttributes = attr
        navBar.setBackgroundImage(#colorLiteral(red: 0.8353131413, green: 0.1960914433, blue: 0.1960920691, alpha: 1).asImage(), for: .default)
        navBar.shadowImage = #imageLiteral(resourceName: "Icon-Blank.png")
    }

    func statusBar() {
        guard customizeStatusBarNeeded else {
            return
        }
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        if let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
            statusBarView.backgroundColor = .white
        }
    }
}
