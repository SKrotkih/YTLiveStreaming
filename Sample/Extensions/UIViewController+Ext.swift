//  UIViewController+Ext.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import UIKit

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
}

extension UIViewController {
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
