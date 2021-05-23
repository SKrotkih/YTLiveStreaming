//
//  BaseViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

/**
    Base functionality for every ViewControllers
 */
class BaseViewController: UIViewController {

    private var leftBarButtonItem: UIBarButtonItem {
        let barButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon-Backbutton"),
                                                 landscapeImagePhone: nil,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(self.backButtonAction(_:)))
        barButtonItem.imageInsets = UIEdgeInsets(top: 0, left: -4.0, bottom: 0, right: 0)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Appearance.shared.statusBarStyle
    }

    @objc func backButtonAction(_: UIBarButtonItem) {
        returnToThePreviousView()
    }
}

// MARK: - Navigation Methods

extension BaseViewController {
    open func returnToThePreviousView() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}
