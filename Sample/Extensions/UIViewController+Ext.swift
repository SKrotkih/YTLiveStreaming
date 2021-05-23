//  UIViewController+Ext.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import SwiftUI

extension UIViewController {
    public func addChildViewController(_ child: UIViewController, autoResize: Bool = true) {
        guard child.parent == nil else {
            return
        }
        addChild(child)
        view.addSubview(child.view)
        if autoResize {
            child.view.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                view.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
                view.topAnchor.constraint(equalTo: child.view.topAnchor),
                view.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
            ]
            constraints.forEach { $0.isActive = true }
            view.addConstraints(constraints)
        }
        child.didMove(toParent: self)
    }

    public func removeChildViewController(_ child: UIViewController) {
        guard child.parent != nil else {
            return
        }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    /// Add a SwiftUI `View` as a child of the input `UIView`.
    /// - Parameters:
    ///   - swiftUIView: The SwiftUI `View` to add as a child.
    ///   - view: The `UIView` instance to which the view should be added.
    func addSubSwiftUIView<Content>(_ swiftUIView: Content, to view: UIView) where Content: View {
        let hostingController = UIHostingController(rootView: swiftUIView)

        /// Add as a child of the current view controller.
        addChild(hostingController)

        /// Add the SwiftUI view to the view controller view hierarchy.
        view.addSubview(hostingController.view)

        /// Setup the contraints to update the SwiftUI view boundaries.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            view.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        /// Notify the hosting controller that it has been moved to the current view controller.
        hostingController.didMove(toParent: self)
    }

    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            if let visibleController = navigation.visibleViewController {
                return visibleController.topMostViewController()
            }
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController?.topMostViewController()
    }
}
