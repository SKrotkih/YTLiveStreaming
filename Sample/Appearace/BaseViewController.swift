//
//  BaseViewController.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import UIKit

class BaseViewController: UIViewController {

    private var leftBarButtonItem: UIBarButtonItem {
        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "icon-Backbutton"),
                                                     landscapeImagePhone: nil,
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(self.backButtonClick(_:)))
        backButton.imageInsets = UIEdgeInsets(top: 0, left: -4.0, bottom: 0, right: 0)
        backButton.tintColor = .white
        return backButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Appearance.statusBarStyle
    }

    @objc func backButtonClick(_: UIBarButtonItem) {
        backActionHandle()
    }

    open func backActionHandle() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}
