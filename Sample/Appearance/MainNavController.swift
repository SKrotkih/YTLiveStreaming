//
//  MainNavController.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import UIKit

class MainNavController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Appearance.shared.statusBarStyle
    }
}
