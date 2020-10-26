//  Appearance
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import UIKit

final class Appearance {

    private init() {
    }

    private static let CustomizeStatusBar = false
    
    static func customize() {
        // Color file template should be added into the project.
        UIApplication.shared.keyWindow?.tintColor = .black
        
        self.customizeNavigationBar()
        self.customizeStatusBar()
    }
    
    static func customizeNavigationBar() {
        
        let navBar = UINavigationBar.appearance()
        
        navBar.tintColor = .white
        
        // Navigation bar title
        let attr: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)
        ]
        navBar.titleTextAttributes = attr
        navBar.setBackgroundImage(#colorLiteral(red: 0.8353131413, green: 0.1960914433, blue: 0.1960920691, alpha: 1).image(), for: .default)
        navBar.shadowImage = #imageLiteral(resourceName: "Icon-Blank.png")
    }
    
    static var statusBarStyle: UIStatusBarStyle {
        return CustomizeStatusBar ? .default : .lightContent
    }
    
    static func customizeStatusBar() {
        if CustomizeStatusBar {
            UINavigationBar.appearance().barStyle = UIBarStyle.black
            if let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
                statusBarView.backgroundColor = .white
            }
        }
    }
}
