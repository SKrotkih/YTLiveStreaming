//
//  MainNavController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

class MainNavController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Appearance.shared.statusBarStyle
    }
}
