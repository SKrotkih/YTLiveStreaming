//
//  UIStoryboard+Ext.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import UIKit

extension UIStoryboard {

    convenience init(_ storyboard: AppRouter.StroyboadType) {
        self.init(name: storyboard.filename, bundle: nil)
    }

    /// Instantiates and returns the view controller with the specified identifier.
    ///
    /// - Parameter identifier: uniquely identifies equals to Class name
    /// - Returns: The view controller corresponding to the specified identifier string. If no view controller is associated with the string, this method throws an exception.
    public func instantiateViewController<T>(_ identifier: T.Type) -> T where T: UIViewController {
        let className = String(describing: identifier)
        guard let vc =  self.instantiateViewController(withIdentifier: className) as? T else {
            fatalError("Cannot find controller with identifier \(className)")
        }
        return vc
    }

    func segueToRootViewController<T>(_ configure: (T) -> Void) where T: UIViewController {
        let id = String(describing: T.self)
        if let viewController = self.instantiateViewController(withIdentifier: id) as? T {
            configure(viewController)
            setUpRootViewController(viewController)
        } else {
            assertionFailure("Failed to open \(id) screen")
        }
    }

    private func setUpRootViewController(_ viewController: UIViewController?) {
        guard let window = AppDelegate.shared.window else {
            assertionFailure()
            return
        }

        if let navController = window.rootViewController as? UINavigationController {
            navController.popToRootViewController(animated: false)
            navController.setViewControllers([], animated: false)
        }
        window.rootViewController = nil

        let vc = viewController ?? self.instantiateInitialViewController()
        window.rootViewController = vc
    }

    func segueToModalViewController<T>(_ configure: (T) -> Void) where T: UIViewController {
        guard let window = AppDelegate.shared.window else {
            assertionFailure()
            return
        }
        let id = String(describing: T.self)
        if let viewController = self.instantiateViewController(withIdentifier: id) as? T {
            configure(viewController)
            window.rootViewController?.present(viewController, animated: false, completion: {
            })
        } else {
            assertionFailure("Failed to open \(id) screen")
        }
    }

    func sequePushViewController<T>(_ configure: (T) -> Void) where T: UIViewController {
        guard let window = AppDelegate.shared.window else {
            assertionFailure()
            return
        }
        if window.rootViewController as? UINavigationController == nil {
            let navController = UINavigationController()
            window.rootViewController = navController
        }
        if let navController = window.rootViewController as? UINavigationController {
            let id = String(describing: T.self)
            if let viewController = self.instantiateViewController(withIdentifier: id) as? T {
                configure(viewController)
                navController.pushViewController(viewController, animated: false)
            } else {
                assertionFailure("Failed to open \(id) screen")
            }
        } else {
            assertionFailure("Failed to open screen")
        }
    }
}

extension UIStoryboard {
    @nonobjc class var main: UIStoryboard {
        return UIStoryboard(name: AppRouter.StroyboadType.main.rawValue, bundle: nil)
    }
}
