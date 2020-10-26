//
//  UIViewController+FullScreen.swift
//  YouTubeLiveVideo
//

import UIKit

extension UIViewController {
  public func addFullScreen(childViewController child: UIViewController) {
    guard child.parent == nil else {
      return
    }
    addChild(child)
    view.addSubview(child.view)

    child.view.translatesAutoresizingMaskIntoConstraints = false
    let constraints = [
      view.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
      view.topAnchor.constraint(equalTo: child.view.topAnchor),
      view.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
    ]
    constraints.forEach { $0.isActive = true }
    view.addConstraints(constraints)

    child.didMove(toParent: self)
  }

  public func remove(childViewController child: UIViewController?) {
    guard let child = child else {
      return
    }
    guard child.parent != nil else {
      return
    }
    child.willMove(toParent: nil)
    child.view.removeFromSuperview()
    child.removeFromParent()
  }
}
