//
//  SwiftUISignInViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import GoogleSignIn

// [START viewcontroller_interfaces]
class SwiftUISignInViewController: BaseViewController {
    // [END viewcontroller_interfaces]

    @Lateinit var viewModel: SignInViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBodyView()
    }

    private func addBodyView() {
        let bodyView = SignInBodyView(viewModel: viewModel)
        addSubSwiftUIView(bodyView, to: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showNavBar(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        showNavBar(false, animated: animated)
    }

    private func showNavBar(_ show: Bool, animated: Bool) {
        self.navigationController?.setNavigationBarHidden(show, animated: animated)
    }
}
